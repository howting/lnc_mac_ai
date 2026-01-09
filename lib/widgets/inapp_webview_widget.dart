// ignore_for_file: avoid_print

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:lncmacai/utils/web_uri.dart';

class InappWebviewWidget extends StatefulWidget {
  InappWebviewWidget(this.url, {super.key});

  String url;

  @override
  InappWebviewWidgetState createState() => InappWebviewWidgetState();
}

class InappWebviewWidgetState extends State<InappWebviewWidget> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String currentUrl = '';
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    currentUrl = widget.url;

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = contextMenuItemClicked.androidId;
          print(
              "onContextMenuActionItemClicked: $id ${contextMenuItemClicked.title}");
        });

    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            options: PullToRefreshOptions(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(21, 21, 21, 1),
          title: const Text(
            "LNC AI Service",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: InkWell(
            child: const Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
            onTap: () => Get.back(),
          ),
        ),
        backgroundColor: const Color.fromARGB(221, 32, 30, 30),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: WebUri(currentUrl)),
                initialUserScripts: UnmodifiableListView<UserScript>([]),
                pullToRefreshController: null,
                onWebViewCreated: (controller) async {
                  webViewController = controller;
                  print(await controller.getUrl());
                },
                onLoadStart: (controller, url) async {
                  setState(() {
                    currentUrl = url.toString();
                    urlController.text = currentUrl;
                  });
                },
                androidOnPermissionRequest:
                    (controller, request, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController?.endRefreshing();
                  setState(() {
                    currentUrl = url.toString();
                    urlController.text = currentUrl;
                  });
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController?.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    urlController.text = currentUrl;
                  });
                },
                onUpdateVisitedHistory: (controller, url, isReload) {
                  setState(() {
                    currentUrl = url.toString();
                    urlController.text = currentUrl;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                },
              ),
              progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container(),
            ],
          ),
        ));
  }
}
