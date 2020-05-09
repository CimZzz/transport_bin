import 'package:console_cmd/console_cmd.dart';
import 'package:transport/transport.dart';
import 'package:transport_bin/option.dart';

const kVersion = '1.0.4';

void main(List<String> arguments) {
	if (arguments.isEmpty) {
		printUnknown(null);
		return;
	}

	List<RootOption> rootOptionList;
	rootOptionList = <RootOption>[
		// version
		RootOption(
			optionName: [
				'--version', '-v', '-version'
			],
			optionList: null,
			info: 'show tansport version',
			rootHandle: (_1, _2) {
				printVersion();
			}
		),

		// help
		RootOption(
			optionName: [
				'-h', '-help', '-H', '--help', '-?'
			],
			optionList: null,
			info: 'show transport usage',
			rootHandle: (_1, _2) {
				printHelp(rootOptionList);
			}
		),

		// proxy server
		RootOption(
			optionName: [
				'-ps', '-proxy', '--proxy-server'
			],
			optionList: [
				// help
				Option(
					optionName: [
						'-h', '-help', '-H', '--help', '-?'
					],
					optionType: OptionType.Type_None,
					valueName: 'help',
					mustOnly: true,
					info: 'show proxy server usage'
				),

				// port
				Option(
					optionName: [
						'-p', '--port'
					],
					optionType: OptionType.Type_Int,
					valueName: 'port',
					info: 'local server port'
				),

				// remote port
				Option(
					optionName: [
						'-rp', '--remote-port'
					],
					optionType: OptionType.Type_Int,
					valueName: 'remotePort',
					info: 'remote server port'
				),

				// remote address
				Option(
					optionName: [
						'-ra', '--remote-address'
					],
					optionType: OptionType.Type_String,
					valueName: 'remoteAddress',
					info: 'remote server address, default 127.0.0.1'
				),

				// listen on intranet
				Option(
					optionName: [
						'-local', '--listen-on-local'
					],
					optionType: OptionType.Type_None,
					valueName: 'local',
					info: 'Server will listen on intranet, extranet not access'
				),
			],
			info: 'start a proxy transport server, transport socket to socket directly',
			rootHandle: (root, valueMap) {
				if (valueMap == null) {
					printUnknown(null, whose: root.selectName);
					return;
				}
				if (valueMap.containsKey('help')) {
					printRootHelp(root);
					return;
				}
				int port = valueMap['port'];
				String rAddress = valueMap['remoteAddress'];
				int rPort = valueMap['remotePort'];
				final local = valueMap.containsKey('local');

				if (port == null) {
					printLackParam(root.selectName, '--port');
					return;
				}
				if (rPort == null) {
					printLackParam(root.selectName, '--remote-port');
					return;
				}

				TransportServer(
					isLocal: local,
					localPort: port,
					transaction: ProxyTransaction(
						logInterface: const ConsoleLogInterface(),
						remoteAddress: rAddress,
						remotePort: rPort,
					)
				)
					..startServer();
			}
		),

		// http proxy server
		RootOption(
			optionName: [
				'-hps', '-http-proxy', '--http-proxy-server'
			],
			optionList: [
				// help
				Option(
					optionName: [
						'-h', '-help', '-H', '--help', '-?'
					],
					optionType: OptionType.Type_None,
					valueName: 'help',
					mustOnly: true,
					info: 'show http proxy server usage'
				),

				// port
				Option(
					optionName: [
						'-p', '--port'
					],
					optionType: OptionType.Type_Int,
					valueName: 'port',
					info: 'local server port'
				),

				// client port
				Option(
					optionName: [
						'-cp', '--client-port'
					],
					optionType: OptionType.Type_Int,
					valueName: 'clientPort',
					info: 'bridge client server port, when config this parameter, http proxy will transport data via bridge client, and bridge client must support \'-custom-address\' feature'
				),

				// client address
				Option(
					optionName: [
						'-ca', '--client-address'
					],
					optionType: OptionType.Type_String,
					valueName: 'clientAddress',
					info: 'bridge client server address, when config this parameter, http proxy will transport data via bridge client, and bridge client must support \'-custom-address\' feature'
				),

				// listen on intranet
				Option(
					optionName: [
						'-local', '--listen-on-local'
					],
					optionType: OptionType.Type_None,
					valueName: 'local',
					info: 'Server will listen on intranet, extranet not access'
				),
			],
			info: 'start a http proxy transport server',
			rootHandle: (root, valueMap) {
				if (valueMap == null) {
					printUnknown(null, whose: root.selectName);
					return;
				}
				if (valueMap.containsKey('help')) {
					printRootHelp(root);
					return;
				}
				int port = valueMap['port'];
				String clientAddress = valueMap['clientAddress'];
				int clientPort = valueMap['clientPort'];
				final local = valueMap.containsKey('local');

				if (port == null) {
					printLackParam(root.selectName, '--port');
					return;
				}

				TransportServer(
					isLocal: local,
					localPort: port,
					transaction: HttpProxyTransaction(
						logInterface: const ConsoleLogInterface(),
						bridgeClientAddress: clientAddress,
						bridgeClientPort: clientPort,
					)
				)
					..startServer();
			}
		),

		// transport client
		RootOption(
			optionName: [
				'-tcs', '--transport-client'
			],
			optionList: [
				// help
				Option(
					optionName: [
						'-h', '-help', '-H', '--help', '-?'
					],
					optionType: OptionType.Type_None,
					valueName: 'help',
					mustOnly: true,
					info: 'show transport server usage'
				),

				// port
				Option(
					optionName: [
						'-p', '--port'
					],
					optionType: OptionType.Type_Int,
					valueName: 'port',
					info: 'local server port'
				),

				// topic
				Option(
					optionName: [
						'-t', '--topic'
					],
					optionType: OptionType.Type_String,
					valueName: 'topic',
					info: 'local transport server topic'
				),

				// remote topic
				Option(
					optionName: [
						'-rt', '--remote-topic'
					],
					optionType: OptionType.Type_String,
					valueName: 'remoteTopic',
					info: 'remote transport server topic'
				),

				// transport port
				Option(
					optionName: [
						'-tp', '--transport-port'
					],
					optionType: OptionType.Type_Int,
					valueName: 'transportPort',
					info: 'transport server port, default 80'
				),

				// transport address
				Option(
					optionName: [
						'-ta', '--transport-address'
					],
					optionType: OptionType.Type_String,
					valueName: 'transportAddress',
					info: 'transport server address, default 127.0.0.1'
				),

				// bridge port
				Option(
					optionName: [
						'-bp', '--bridge-port'
					],
					optionType: OptionType.Type_Int,
					valueName: 'bridgePort',
					info: 'bridge server port'
				),

				// bridge address
				Option(
					optionName: [
						'-ba', '--bridge-address'
					],
					optionType: OptionType.Type_String,
					valueName: 'bridgeAddress',
					info: 'bridge server address'
				),

				// peer port
				Option(
					optionName: [
						'-pp', '--peer-port'
					],
					optionType: OptionType.Type_Int,
					valueName: 'peerPort',
					info: 'Peer client transport port (Peer client must support \`customAddress\` feature)'
				),

				// peer address
				Option(
					optionName: [
						'-pa', '--peer-address'
					],
					optionType: OptionType.Type_String,
					valueName: 'peerAddress',
					info: 'Peer client transport address (Peer client must support \`customAddress\` feature)'
				),

				// custom address
				Option(
					optionName: [
						'-cusaddr', '--custom-address'
					],
					optionType: OptionType.Type_None,
					valueName: 'customAddress',
					info: 'Allow socket specify transport address and port, but must support data format'
				),

				// rsa public key path
				Option(
					optionName: [
						'-rsa', '--rsa-public'
					],
					optionType: OptionType.Type_String,
					valueName: 'rsaPublic',
					info: 'RSA Public key file path'
				),

				// listen on intranet
				Option(
					optionName: [
						'-local', '--listen-on-local'
					],
					optionType: OptionType.Type_None,
					valueName: 'local',
					info: 'Server will listen on intranet, extranet not access'
				),
			],
			info: 'start a transport client server, via transport bridge server, reach which server bound specify topic, and other transport server also can reach this server by topic',
			rootHandle: (root, valueMap) {
				if (valueMap == null) {
					printUnknown(null, whose: root.selectName);
					return;
				}
				if (valueMap.containsKey('help')) {
					printRootHelp(root);
					return;
				}
				int port = valueMap['port'];
				String topic = valueMap['topic'];
				String remoteTopic = valueMap['remoteTopic'];
				String transportAddress = valueMap['transportAddress'];
				int transportPort = valueMap['transportPort'];
				String bridgeAddress = valueMap['bridgeAddress'];
				int bridgePort = valueMap['bridgePort'];
				String peerAddress = valueMap['peerAddress'];
				int peerPort = valueMap['peerPort'];
				var customAddress = valueMap.containsKey('customAddress');
				String rsaPublic = valueMap['rsaPublic'];
				final local = valueMap.containsKey('local');

				if (port == null) {
					printLackParam(root.selectName, '--port');
					return;
				}

				if (topic == null) {
					printLackParam(root.selectName, '--topic');
					return;
				}

				if (remoteTopic == null) {
					printLackParam(root.selectName, '--remote-topic');
					return;
				}

				if (bridgeAddress == null) {
					printLackParam(root.selectName, '--bridge-address');
					return;
				}

				if (bridgePort == null) {
					printLackParam(root.selectName, '--bridge-port');
					return;
				}

				final isPeerCustomTransport = peerAddress != null || peerPort != null;

				if(!customAddress && transportAddress == null && transportPort == null) {
					printWarn('This client do not support transport...');
				}

				TransportServer(
					isLocal: local,
					localPort: port,
					transaction: BridgeClientTransaction(
						logInterface: ConsoleLogInterface(),
						topic: topic,
						remoteTopic: remoteTopic,
						transportAddress: transportAddress,
						transportPort: transportPort,
						isCustomTransport: customAddress,
						bridgeAddress: bridgeAddress,
						bridgePort: bridgePort,
						peerAddress: peerAddress,
						peerPort: peerPort,
						isPeerCustomTransport: isPeerCustomTransport,
						rsaPublicKeyPath: rsaPublic,
					)
				)
				..startServer();

			}
		),

		// transport bridge
		RootOption(
			optionName: [
				'-tbs', '-transport-bridge'
			],
			optionList: [
				// help
				Option(
					optionName: [
						'-h', '-help', '-H', '--help', '-?'
					],
					optionType: OptionType.Type_None,
					valueName: 'help',
					mustOnly: true,
					info: 'show transport bridge server usage'
				),

				// port
				Option(
					optionName: [
						'--port', '-p'
					],
					optionType: OptionType.Type_Int,
					valueName: 'port',
					info: 'local server port'
				),

				// rsa private key path
				Option(
					optionName: [
						'--rsa-private', '-rsa'
					],
					optionType: OptionType.Type_String,
					valueName: 'rsaPrivate',
					info: 'RSA Private key file path'
				),

				// listen on intranet
				Option(
					optionName: [
						'-local', '--listen-on-local'
					],
					optionType: OptionType.Type_None,
					valueName: 'local',
					info: 'Server will listen on intranet, extranet not access'
				),
			],
			info: 'start a transport bridge server, allow transport server connected this can access each other',
			rootHandle: (root, valueMap) {
				if (valueMap == null) {
					printUnknown(null, whose: root.selectName);
					return;
				}
				if (valueMap.containsKey('help')) {
					printRootHelp(root);
					return;
				}
				int port = valueMap['port'];
				String rsaPrivate = valueMap['rsaPrivate'];
				final local = valueMap.containsKey('local');

				if (port == null) {
					printLackParam(root.selectName, '--port');
					return;
				}

				TransportServer(
					isLocal: local,
					localPort: port,
					transaction: BridgeServerTransaction(
						logInterface: const ConsoleLogInterface(),
						rsaPrivateKeyPath: rsaPrivate
					)
				)
				..startServer();
			}
		),
	];

	final firstParams = arguments[0];
	RootOption rootOption;
	for (var root in rootOptionList) {
		if (root.optionName.contains(firstParams)) {
			rootOption = root;
			rootOption.selectName = firstParams;
			break;
		}
	}

	if (rootOption == null) {
		printUnknown(firstParams);
		return;
	}

	arguments = arguments.sublist(1);
	Option currentOption;
	var hasOther = false;
	var only = false;
	var isOver = true;
	for (final arg in arguments) {
		if (isOver) {
			isOver = false;
			if (only) {
				printMustOnly(rootOption.selectName, currentOption.selectName);
			}
			currentOption = null;

			if (rootOption.optionList == null) {
				printUnknown(arg, whose: rootOption.selectName);
				return;
			}
			for (final option in rootOption.optionList) {
				if (option.optionName.contains(arg)) {
					currentOption = option;
					currentOption.selectName = arg;
					break;
				}
			}

			if (currentOption == null) {
				printUnknown(arg, whose: rootOption.selectName);
				return;
			}

			if (rootOption.checkOptionExist(currentOption.valueName)) {
				printRepeat(rootOption.selectName, currentOption.selectName);
				return;
			}

			if (currentOption.mustOnly == true) {
				if (hasOther) {
					printMustOnly(rootOption.selectName, currentOption.selectName);
					return;
				}
				else {
					only = true;
				}
			}

			if(currentOption.optionType == OptionType.Type_None) {
				rootOption.addOption(currentOption.valueName, null);
				isOver = true;
			}
		}
		else {
			switch (currentOption.optionType) {
				case OptionType.Type_Int:
					final intValue = int.tryParse(arg);
					if (intValue == null) {
						printUnknown(arg, whose: rootOption.selectName, optionName: currentOption.selectName);
						return;
					}
					rootOption.addOption(currentOption.valueName, intValue);
					isOver = true;
					break;
				case OptionType.Type_String:
					rootOption.addOption(currentOption.valueName, arg);
					isOver = true;
					break;
				case OptionType.Type_None:
					printNoNeedParams(rootOption.selectName, currentOption.selectName);
					return;
			}
		}
	}

	if (isOver) {
		currentOption = null;
	}

	if (currentOption != null) {
		if (currentOption.optionType != OptionType.Type_None) {
			printLackParam(rootOption.selectName, currentOption.selectName);
			return;
		}
	}

	rootOption.perform();
}


void printUnknown(String msg, {String whose, String optionName}) {
	print('');
	var printMsg = '';
	if (msg != null) {
		if (whose != null) {
			if (optionName != null) {
				printMsg = 'Unrecognized `$whose $optionName` value: $msg';
			}
			else {
				printMsg = 'Unrecognized `$whose` option: $msg';
			}
		}
		else {
			printMsg = 'Unrecognized option: $msg';
		}
	}
	else {
		printMsg = 'Option must not be empty';
	}

	ANSIPrinter()
		..printRGB('Error: $printMsg', fColor: 0xFF0000)
		..print('');
	if (whose != null) {
		print('Use transport $whose \'-h\' or \'-help\' to show the usage');
	}
	else {
		print('Use \'-h\' or \'-help\' to show the usage');
	}

	print('');
}


void printWarn(String msg) {
	ANSIPrinter().printRGB('Warn: $msg', fColor: 0xFFFF00);
}

void printLackParam(String whose, String what) {
	ANSIPrinter().printRGB('Error: `$whose` miss `$what` parameter', fColor: 0xFF0000);
}

void printRepeat(String whose, String option) {
	ANSIPrinter().printRGB('Error: `$whose` has repeat `$option` parameter', fColor: 0xFF0000);
}

void printNoNeedParams(String whose, String option) {
	ANSIPrinter().printRGB('Error: `$whose $option` no need parameter', fColor: 0xFF0000);
}

void printMustOnly(String whose, String option) {
	ANSIPrinter().printRGB('Error: `$whose $option` must only', fColor: 0xFF0000);
}

void printHelp(List<RootOption> rootOptions) {
	ANSIPrinter()
		..print('')..print('transport usage: ')..print('');

	for (final option in rootOptions) {
		ANSIPrinter()
			..printRGB('${spaceString(option.optionName.join(', '), 48)}', breakLine: false)..printRGB(' ${option.info}');
	}


	ANSIPrinter()..print('');
}

void printRootHelp(RootOption rootOption) {
	ANSIPrinter()
		..print('')..print('${rootOption.selectName} usage: ')..print('');

	for (final option in rootOption.optionList) {
		var valueName = '';
		switch (option.optionType) {
			case OptionType.Type_String:
				valueName = '<string>';
				break;
			case OptionType.Type_Int:
				valueName = '<int>';
				break;
			case OptionType.Type_None:
				valueName = '';
				break;
		}
		ANSIPrinter()
			..printRGB('${spaceString('${option.optionName.join(', ')} $valueName', 48)}', breakLine: false)..printRGB(' ${option.info}');
	}

	ANSIPrinter()..print('');
}

void printVersion() {
	ANSIPrinter()..print('transport, author CimZzz, version code ', breakLine: false)
	..printRGB('$kVersion', fColor: 0x00BF00, bColor: 0xFFFFFF)
	..print('base on ', breakLine: false)
	..printRGB('transport: 1.0.6', fColor: 0x00BF00, bColor: 0xFFFFFF)
	..print('contact with me:', breakLine: false)
	..printRGB('a1950207@gmail.com', fColor: 0x00BF00, bColor: 0xFFFFFF)
	..print('');
}


String spaceString(String str, int spaceCount) {
	var disCount = spaceCount - str.length;
	if (disCount <= 0) {
		return str;
	}

	while (disCount -- > 0) {
		str += ' ';
	}

	return str;
}