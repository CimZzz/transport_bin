import 'package:args/args.dart';
import 'package:console_cmd/console_cmd.dart';
import 'package:transport/transport.dart';

const kVersion = '1.0.5';

class _Parser {
  _Parser(this.name, this.parser);
  final String name;
  final ArgParser parser;
}

class ServerItem {
  final String ip;
  final int port;
  final String clientId;

  ServerItem(this.ip, this.port, this.clientId);
  @override
  String toString() => 'ServerItem(ClientId: $clientId, IP: $ip, Port: $port)';
}

void main(List<String> args) {
  final parser = _Parser('transport', ArgParser());
  final bridge = _Parser('bridge', ArgParser());
  bridge.parser
    ..addFlag('help', abbr: 'h', help: 'Print bridge server usage')
    ..addOption(
      'port',
      abbr: 'p',
      defaultsTo: '7127',
      help: 'Which port that bridge server listen on (0~65535)',
    );

  final client = _Parser('client', ArgParser());
  client.parser
    ..addFlag('help', abbr: 'h', help: 'Print client server usage')
    ..addOption('cid', help: '* Proxy client id in bridge server')
    ..addOption('bip', help: '* Configurate bridge server ip / host')
    ..addOption('bp',
        defaultsTo: '7127', help: 'Configurate bridge server port')
    ..addOption('ip',
        defaultsTo: '0.0.0.0', help: 'Configurate client server ip')
    ..addOption('port',
        defaultsTo: '7128', help: 'Configurate client server port')
    ..addOption('pip',
        defaultsTo: '0.0.0.0',
        help: 'Configurate which ip / host you wanna access via proxy server')
    ..addOption('pp',
        help: '* Configurate which port you wanna access via proxy server');

  final proxy = _Parser('proxy', ArgParser());
  proxy.parser
    ..addFlag('help', abbr: 'h', help: 'Print proxy server usage')
    ..addMultiOption('bridge',
        abbr: 'b',
        help:
            'Configurate client-id、ip / host and port for bridge server. If bridge server addr is 0.0.0.0:7127, client-id is CimZzz, you can set like this: CimZzz@0.0.0.0:7127 or CimZzz@0.0.0.0 (Port default is 7127). you can config multi server');

  parser.parser
    ..addCommand('bridge', bridge.parser)
    ..addCommand('client', client.parser)
    ..addCommand('proxy', proxy.parser)
    ..addFlag('version', abbr: 'v', help: 'Print the version information')
    ..addFlag('help', abbr: 'h', help: 'Print all usage');

  try {
    final results = parser.parser.parse(args);
    final isHelp = results['help'];
    final isVersion = results['version'];
    if (isHelp == true && isVersion == true) {
      throw Exception('wrong arguments');
    }
    if ((isHelp == true || isVersion == true) && results.command != null) {
      throw Exception('wrong arguments');
    }

    if (isHelp) {
      printHelp([parser, bridge, client, proxy]);
      return;
    } else if (isVersion) {
      printVersion();
      return;
    }

    final command = results.command;
    if (command == null) {
      printHelp([parser, bridge, client, proxy]);
      return;
    }
    switch (command.name) {
      case 'bridge':
        final isHelp = command['help'];
        final port = command['port'];
        if (isHelp == true && port != null) {
          throw Exception('wrong arguments');
        }
        if (isHelp) {
          printHelp([bridge]);
        } else if (port != null) {
          final portNum = int.tryParse(port);
          if (portNum == null || portNum < 0 || portNum > 0xFFFF) {
            // 非法端口号
            throw Exception('port must be number(0~65535)');
          }
          TransportBridge.listen(TransportBridgeOptions(port: portNum));
        } else {
          printHelp([bridge]);
        }
        break;
      case 'client':
        final serverInfo = command.rest.isNotEmpty
            ? parserServerItem(command.rest[0], defaultPort: 7127)
            : null;
        final isHelp = command['help'];
        final cid = command['cid'] ?? serverInfo.clientId;
        final bip = command['bip'] ?? serverInfo.ip;
        final bp = int.tryParse(command['bp']) ?? serverInfo.port;
        final ip = command['ip'];
        final port = int.tryParse(command['port']);
        final pip = command['pip'];
        final pp = int.tryParse(command['pp']);
        if (cid != null &&
            bip != null &&
            bp != null &&
            ip != null &&
            port != null &&
            pip != null &&
            pp != null) {
          if (isHelp) {
            throw Exception('wrong arguments');
          }
          RequestServer.listen(
              option: RequestServerOption(
            clientId: cid,
            ipAddress: bip,
            port: bp,
            localIpAddress: ip,
            localPort: port,
            proxyIpAddress: pip,
            proxyPort: pp,
          ));
        } else {
          printHelp([client]);
        }
        break;

      case 'proxy':
        final isHelp = command['help'];
        var bridge = command['bridge'];
        if (bridge != null) {
          if (isHelp) {
            throw Exception('wrong arguments');
          }
          if (bridge is List) {
            final registrarSet = bridge.map((str) {
              final info = parserServerItem(str, defaultPort: 7127);
              if (info == null) {
                throw Exception('wrong server format');
              }
              return info;
            }).map((serverItem) {
              return ResponseRegistrar(
                  ipAddress: serverItem.ip,
                  port: serverItem.port,
                  clientId: serverItem.clientId);
            }).toSet();
            ResponseSocket.bindBridge(
                option: ResponseSocketOption(registrar: registrarSet));
          } else {
            throw Exception('wrong arguments');
          }
        } else {
          printHelp([proxy]);
        }
        break;
    }
  } catch (error) {
    printError(error.toString());
  }
}

ServerItem parserServerItem(String arg, {int defaultPort}) {
  if (arg == null) {
    return null;
  }
  var idx = arg.indexOf('@');
  if (idx == -1 || idx == 0) {
    return null;
  }

  final clientId = arg.substring(0, idx);
  var nextIdx = arg.indexOf(':', idx + 1);
  if (nextIdx == 0) {
    return null;
  } else if (nextIdx == -1) {
    if (defaultPort == null) {
      return null;
    }
    return ServerItem(arg.substring(idx + 1), defaultPort, clientId);
  }
  final ip = arg.substring(idx + 1, nextIdx);
  final port = int.tryParse(arg.substring(nextIdx + 1));
  if (port == null) {
    return null;
  }
  return ServerItem(ip, port, clientId);
}

void printError(String msg) {
  ANSIPrinter().printRGB('Error: $msg', fColor: 0xFF0000);
}

void printHelp(List<_Parser> argParsers) {
  var isFirst = true;
  for (final argParser in argParsers) {
    if (isFirst) {
      isFirst = false;
      print('${argParser.name} usage >> \n');
    } else {
      print('\n${argParser.name}:\n');
    }
    print(argParser.parser.usage);
  }
}

void printVersion() {
  ANSIPrinter()
    ..print('transport, author CimZzz, version code ', breakLine: false)
    ..printRGB('$kVersion', fColor: 0x00BF00, bColor: 0xFFFFFF)
    ..print('base on ', breakLine: false)
    ..printRGB('transport: 1.0.7', fColor: 0x00BF00, bColor: 0xFFFFFF)
    ..print('contact with me:', breakLine: false)
    ..printRGB('a1950207@163.com', fColor: 0x00BF00, bColor: 0xFFFFFF)
    ..print('');
}
