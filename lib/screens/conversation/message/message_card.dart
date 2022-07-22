import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_mobile_ui/components/avatar.dart';
import 'package:social_network_mobile_ui/components/time_bar.dart';
import 'package:social_network_mobile_ui/constants/color.dart';
import 'package:social_network_mobile_ui/models/conversation.dart';
import 'package:social_network_mobile_ui/models/message.dart';
import 'package:social_network_mobile_ui/models/message_interaction.dart';
import 'package:social_network_mobile_ui/screens/conversation/bloc/conversation_bloc.dart';
import 'package:social_network_mobile_ui/screens/conversation/message/components/chat_bubble_triangle.dart';
import 'package:social_network_mobile_ui/screens/conversation/message/components/message_status.dart';
import 'package:social_network_mobile_ui/screens/conversation/message/components/reaction_bar.dart';
import 'package:social_network_mobile_ui/screens/conversation/message/components/reaction_status.dart';
import 'package:social_network_mobile_ui/screens/conversation/message/components/seen_info.dart';
import 'package:social_network_mobile_ui/screens/conversation/message/components/text_card.dart';

class MessageCard extends StatefulWidget {
  Message message;
  Conversation conversation;
  bool showDate;
  bool showAvatar;
  bool needMessageStatus = false;

  MessageCard(
      {required this.message,
      required this.conversation,
      required this.showDate,
      required this.showAvatar,
      required this.needMessageStatus});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  bool showDetail = false;
  late ConversationBloc bloc;
  Map<String, List<String>> reactionDetails = Map();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc = BlocProvider.of<ConversationBloc>(context);
    if (widget.message.interactions != null) {
      for (MessageInteraction detail in widget.message.interactions!) {
        // if (detail.seenBy.id != widget.chatBox.currentUser.id) {
        //   guestMessageDetail = detail;
        // }
        if (detail.reaction != null) {
          String? name = detail.seenBy.nickName;
          if (name == null) name = detail.seenBy.user.name;
          if (reactionDetails[detail.reaction!.code] == null) {
            reactionDetails[detail.reaction!.code] = [];
          }
          reactionDetails[detail.reaction!.code]!.add(name);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) => _buildView(context));
  }

  Widget _buildView(BuildContext context) {
    bool isSender = widget.message.sender.id == widget.conversation.user.id;
    final messenger = widget.message.sender;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.showDate || showDetail
              ? TimeBar(time: widget.message.createdDate)
              : Container(),
          Row(
            mainAxisAlignment:
                isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              !isSender && widget.showAvatar
                  ? Container(
                      margin: EdgeInsets.only(right: 5),
                      child: Avatar(
                        url: messenger.user.avatar.url,
                        size: 35,
                      ))
                  : Container(
                      height: 35,
                      width: 40,
                    ),
              InkWell(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                onTap: () {
                  setState(() {
                    showDetail = !showDetail;
                  });
                },
                onLongPress: () {
                  showReactionBar();
                },
                child: Stack(children: [
                  Padding(
                    padding: reactionDetails.isNotEmpty
                        ? EdgeInsets.only(left: 8, right: 6, bottom: 7)
                        : EdgeInsets.only(left: 8, right: 6),
                    child: TextCard(
                      text: widget.message.content,
                      color: getColor(widget.conversation.color),
                    ),
                  ),
                  isSender
                      ? Positioned(
                          bottom: reactionDetails.isNotEmpty ? 4 : -3,
                          right: 8,
                          child: CustomPaint(
                            painter: ChatBubbleTriangle(
                                isSender: isSender,
                                color: getColor(widget.conversation.color)),
                          ))
                      : Container(),
                  reactionDetails.isNotEmpty
                      ? Positioned(
                          bottom: -1,
                          right: 15,
                          child: ReactionStatus(reactionDetails))
                      : Container(),
                ]),
              ),
              widget.needMessageStatus
                  ? MessageStatus(
                      currentUser: widget.conversation.user,
                      message: widget.message,
                      color: widget.conversation.color,
                    )
                  : Container(
                      height: 14,
                      width: 14,
                    ),
            ],
          ),
          showDetail
              ? SeenInfo(
                  isSender: isSender,
                  interactions: widget.message.interactions,
                )
              : Container(),
        ]);
  }

  void showReactionBar() {
    showDialog(
        builder: (context) => Hero(
              tag: 'dash',
              child: ReactionBar(
                callBack: (value) {
                  bloc.add(UpdateMessageEvent(
                      type: "reaction",
                      value: value,
                      messageId: widget.message.id));
                },
              ),
            ),
        context: context);
  }
}
