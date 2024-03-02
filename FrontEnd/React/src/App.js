import {
	Button,
	Container,
	Text,
	Title,
	Modal,
	TextInput,
	Group,
	Card,
	ActionIcon
} from '@mantine/core';
import { useState, useRef, useEffect } from 'react';
import { MoonStars, Sun, Trash, Plus } from 'tabler-icons-react';

import {
	MantineProvider,
	ColorSchemeProvider
} from '@mantine/core';
import { useColorScheme } from '@mantine/hooks';
import { useHotkeys, useLocalStorage } from '@mantine/hooks';
import Divider from './divier.js';
import lighthouse from '@lighthouse-web3/sdk';

export default function App() {
	const [imageFile, setImageFile] = useState(null);
	const [audioFile, setAudioFile] = useState(null);
	const [audioDuration, setAudioDuration] = useState(null);

	const [tasks, setTasks] = useState([]);
	const [opened, setOpened] = useState(false);
	const [newMusicOpened, setNewMusicOpened] = useState(false);
	const [currentPlaylistIndex, setCurrentPlaylistIndex] = useState(0);
	const [finalJSON, setFinalJSON] = useState([]);

	const preferredColorScheme = useColorScheme();
	const [colorScheme, setColorScheme] = useLocalStorage({
		key: 'mantine-color-scheme',
		defaultValue: 'light',
		getInitialValueInEffect: true,
	});
	const toggleColorScheme = value =>
		setColorScheme(value || (colorScheme === 'dark' ? 'light' : 'dark'));

	useHotkeys([['mod+J', () => toggleColorScheme()]]);

	const taskTitle = useRef('');
	const taskSummary = useRef('');

	const songTitle = useRef('');
	const songArtist = useRef('');

	function createTask() {
		const uuid = uuidv4()
		setTasks([
			...tasks,
			{
				id: uuid,
				title: taskTitle.current.value,
				summary: taskSummary.current.value,
				image: imageFile, // Store the image file object or its data URL
				songs: [],
			},
		]);

		// Call saveTasks with the new list, including images and audio
		saveTasks([
			...tasks,
			{
				id: uuid,
				title: taskTitle.current.value,
				summary: taskSummary.current.value,
				image: imageFile,
				songs: []
			},
		]);

		// Log each task as a stringified JSON
		tasks.forEach((task, index) => {
			console.log(`Task ${index}: ${JSON.stringify(task)}`);
		});
	}

	function deleteTask(index) {
		var clonedTasks = [...tasks];

		clonedTasks.splice(index, 1);

		setTasks(clonedTasks);

		saveTasks([...clonedTasks]);
	}

	const pinFileToIPFS = async (file) => {
		const apiKey = "API-KEY-FOR-LIGHTHOUSE-HERE";
		var result = ""
		const url = URL.createObjectURL(file);
		const execute = async file => {
			var resp = {};
			await convertBlobUrlToBase64(file).then(async buffer => {
				await lighthouse.uploadBuffer(buffer, apiKey).then(res => {
					console.log(`DEBUG: RESULT PIN FILE - ${JSON.stringify(res)}`);
					resp = res.data;
				});
				console.log(`DEBUG: RESULT PIN FILE - ${JSON.stringify(resp)}`);
			});
			return resp.Hash;
		};

		await execute(url).then(res => {
			result = res;
		});

		console.log(`DEBUG: RESULT PIN FILE - ${result}`);

		return result;
	};

	function deleteSong(songIndex, playlistIndex) {
		var clonedPlaylist = tasks[playlistIndex]
		clonedPlaylist.songs.splice(songIndex, 1);

		var clonedTasks = [...tasks];
		clonedTasks[playlistIndex] = clonedPlaylist;
		setTasks(clonedTasks);
		saveTasks([...clonedTasks]);

	}

	function loadTasks() {
		let loadedTasks = localStorage.getItem('tasks');

		let tasks = JSON.parse(loadedTasks);

		if (tasks) {
			setTasks(tasks);
		}
	}

	function addMusicToPlaylist(index) {
		console.log(finalJSON);
		setCurrentPlaylistIndex(index)
		setNewMusicOpened(true)
	}

	function convertBlobUrlToBase64(blobUrl) {
		return fetch(blobUrl) // Step 1: Fetch the Blob
			.then(response => response.blob()) // Retrieve the Blob from the response
			.then(blob => new Promise((resolve, reject) => { // Step 2: Read the Blob
				const reader = new FileReader();
				reader.onloadend = () => resolve(reader.result); // This is the Base64 string
				reader.onerror = reject;
				reader.readAsDataURL(blob); // Read the Blob as a Data URL (Base64)
			}));
	}

	const mintPlaylist = async () => {
		tasks.forEach(async (task) => {
			const handleFileUpload = async (task) => {
				await pinFileToIPFS(task.image).then(res => {
					console.log(`File successfully uploaded to IPFS with hash: ${res}`);
					var songHashes = []
					task.songs.forEach(async (song, idx) => {
						await handleSongUpload(song).then(result => {
							songHashes.push(result);
						}).finally(() => {
							if (task.songs.length == idx + 1) {
								finish();
							}
						});
					});

					function finish() {
						var finalStructure = {
							id: uuidv4(),
							playlistTitle: task.title,
							playlistDescription: task.summary,
							image: res, // Store the image file object or its data URL
							songs: songHashes,
						}
						console.log(JSON.stringify(finalStructure));
						var oldJSON = [...finalJSON];
						oldJSON.push(finalStructure);
						setFinalJSON(oldJSON)
					}
				});
			};
			await handleFileUpload(task);
		});
	}

	const uploadAssetToIPFS = async (file) => {
		// Upload file using pinFileToIPFS or similar function
		const result = await pinFileToIPFS(file);
		return result; // Assuming the hash is directly returned
	};

	const uploadSongMetadataToIPFS = async (metadata) => {
		const blob = new Blob([JSON.stringify(metadata)], { type: 'application/json' });
		const metadataFile = new File([blob], "metadata.json", { type: "application/json" });
		const result = await pinFileToIPFS(metadataFile);
		return result; // Assuming the hash is directly returned
	};

	const handleSongUpload = async (song) => {
		try {
			var metadata
			// Step 1: Upload cover art and song file to IPFS
			const coverArtHash = await uploadAssetToIPFS(song.albumCover);
			await uploadAssetToIPFS(song.song).then(async songFileHash => {
				// Step 2: Create metadata for the song
				metadata = song;
				metadata.albumCover = coverArtHash;
				metadata.song = songFileHash;

				// Step 3: Upload the metadata object to IPFS
				await uploadSongMetadataToIPFS(metadata).then(metadataHash => {
					console.log(`Song metadata IPFS hash: ${metadataHash}`);
				});
			});

			return metadata;
			// Store metadataHash in state or database as needed
		} catch (error) {
			console.error("Error uploading song assets to IPFS:", error);
		}
	};

	const handleAudioChange = (event) => {
		if (event.target.files && event.target.files[0]) {
			const file = event.target.files[0];
			const audioUrl = URL.createObjectURL(file);

			// Create an audio object to load the file and read its metadata
			const audioObj = new Audio(audioUrl);
			audioObj.addEventListener('loadedmetadata', () => {
				const duration = audioObj.duration;
				const hours = Math.floor(duration / 3600);
				const minutes = Math.floor((duration % 3600) / 60);
				const seconds = Math.floor(duration % 60);

				setAudioDuration({ hours, minutes, seconds });
			});

			setAudioFile(file); // Assuming you store the URL for rendering or other purposes
		}
	};

	function uuidv4() {
		return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
			.replace(/[xy]/g, function (c) {
				const r = Math.random() * 16 | 0,
					v = c == 'x' ? r : (r & 0x3 | 0x8);
				return v.toString(16);
			});
	}

	function addMusic() {
		const song = {
			id: uuidv4(),
			songTitle: songTitle.current.value,
			artist: songArtist.current.value,
			song: audioFile,
			duration: audioDuration,
			albumCover: imageFile
		};
		const updatedTasks = [...tasks];
		updatedTasks[currentPlaylistIndex].songs.push(song);
		setTasks(updatedTasks);
		saveTasks([...updatedTasks]);
	}

	function saveTasks(tasks) {
		localStorage.setItem('tasks', JSON.stringify(tasks));
	}

	const handleImageChange = (event) => {
		if (event.target.files && event.target.files[0]) {
			const file = event.target.files[0];
			// const imageUrl = URL.createObjectURL(file);
			setImageFile(file); // Store the image URL instead of the file itself
		}
	};

	useEffect(() => {
		loadTasks();
	}, []);

	return (
		<ColorSchemeProvider colorScheme={colorScheme} toggleColorScheme={toggleColorScheme}>
			<MantineProvider theme={{ colorScheme, defaultRadius: 'md' }} withGlobalStyles withNormalizeCSS>
				<div className='App'>
					<Modal
						opened={newMusicOpened}
						size={'md'}
						title={'Insert'}
						withCloseButton={false}
						onClose={() => {
							setNewMusicOpened(false);
						}}
						centered>
						<TextInput
							mt={'md'}
							ref={songTitle}
							placeholder={'Music Title'}
							required
							label={'Title'}
						/>
						<TextInput
							ref={songArtist}
							mt={'md'}
							placeholder={'Music Artist'}
							label={'Artist'}
						/>
						<Group mt={'md'} grow>
							<div>
								<Text>Album Cover</Text>
								<input
									type="file"
									accept="image/*"
									onChange={(event) => handleImageChange(event)}
								/>
							</div>
							<div>
								<Text>Music</Text>
								<input
									type="file"
									accept=".mp3, .wav"
									onChange={(event) => handleAudioChange(event)}
								/>
							</div>
						</Group>
						<Group mt={'md'} position={'apart'}>
							<Button
								onClick={() => {
									setNewMusicOpened(false);
								}}
								variant={'subtle'}>
								Cancel
							</Button>
							<Button
								onClick={() => {
									addMusic();
									setNewMusicOpened(false);
								}}>
								Add Music
							</Button>
						</Group>
					</Modal>
					<Modal
						opened={opened}
						size={'md'}
						title={'New Playlist'}
						withCloseButton={false}
						onClose={() => {
							setOpened(false);
						}}
						centered>
						<TextInput
							mt={'md'}
							ref={taskTitle}
							placeholder={'Playlist Title'}
							required
							label={'Title'}
						/>
						<TextInput
							ref={taskSummary}
							mt={'md'}
							placeholder={'Playlist Description'}
							label={'Description'}
						/>
						<Group mt={'md'} grow>
							<div>
								<Text>Album Cover</Text>
								<input
									type="file"
									accept="image/*"
									onChange={(event) => handleImageChange(event)}
								/>
							</div>
						</Group>
						<Group mt={'md'} position={'apart'}>
							<Button
								onClick={() => {
									setOpened(false);
								}}
								variant={'subtle'}>
								Cancel
							</Button>
							<Button
								onClick={() => {
									createTask();
									setOpened(false);
								}}>
								Create Playlist
							</Button>
						</Group>
					</Modal>
					<Container size={550} my={40}>
						<Group position={'apart'}>
							<Title sx={theme => ({ fontFamily: `Greycliff CF, ${theme.fontFamily}`, fontWeight: 900 })}>
								My Playlists
							</Title>
							<ActionIcon color={'blue'} onClick={() => toggleColorScheme()} size='lg'>
								{colorScheme === 'dark' ? <Sun size={16} /> : <MoonStars size={16} />}
							</ActionIcon>
						</Group>
						<Group position={'center'} mt="md">
							<Button
								onClick={() => {
									setOpened(true);
								}}
								fullWidth
								mt={'md'}>
								New Playlist
							</Button>
							<Button
								onClick={() => {
									mintPlaylist().then(res => {
										console.log(`DEBUG: RESULT - ${res}`);
									});
								}}
								fullWidth
								mt={'md'}>
								Mint Playlists
							</Button>
						</Group>
						{tasks.map((task, index) => (
							<Card key={task.id}>
								<Card withBorder mt={'sm'} style={{ display: 'flex', alignItems: 'center' }}>
									{/* {task.image && <img src={URL.createObjectURL(task.image)} alt="Album Cover" style={{ width: '80px', height: '80px', marginRight: '20px' }} />} */}
									<div>
										<Text weight={'bold'}>{task.title}</Text>
										<Text color={'dimmed'} size={'md'}>
											{task.summary ? task.summary : 'No description.'}
										</Text>
									</div>
									<ActionIcon
										onClick={() => addMusicToPlaylist(index)}
										color={'green'}
										variant={'transparent'}
										style={{ marginLeft: '55%' }}>
										<Plus />
									</ActionIcon>
									<ActionIcon
										onClick={() => deleteTask(index)}
										color={'red'}
										variant={'transparent'}
										style={{ marginLeft: 'auto' }}>
										<Trash />
									</ActionIcon>
								</Card>
								<Card>
									{task.songs.map((song, songIndex) => (
										<Card withBorder mt={'sm'} style={{ display: 'flex', alignItems: 'center' }}>
											{/* {song.albumCover && <img src={URL.createObjectURL(song.albumCover)} alt="Album Cover" style={{ width: '80px', height: '80px', marginRight: '20px' }} />} */}
											<div>
												<Text style={{ marginLeft: '100px' }}>{song.songTitle}</Text>
												<Text style={{ marginLeft: '100px' }}>{song.artist}</Text>
											</div>
											<ActionIcon
												onClick={() => deleteSong(songIndex, index)}
												color={'red'}
												variant={'transparent'}
												style={{ marginLeft: '20%' }}>
												<Trash />
											</ActionIcon>
										</Card>
									))}
								</Card>
								<Divider />
							</Card>
						))}
					</Container>
				</div>
			</MantineProvider>
		</ColorSchemeProvider>
	);
}
