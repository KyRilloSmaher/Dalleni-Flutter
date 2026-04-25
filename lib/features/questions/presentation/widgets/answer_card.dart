import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/question_entity.dart';

class AnswerCard extends StatefulWidget {
  const AnswerCard({
    super.key,
    required this.answer,
    this.onUpvote,
    this.onDownvote,
    this.onReply,
  });

  final Answer answer;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final VoidCallback? onReply;

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  // Local optimistic state
  bool _isUpvoted = false;
  bool _isDownvoted = false;
  late int _upvotes;

  @override
  void initState() {
    super.initState();
    _upvotes = widget.answer.upvotes;
  }

  void _handleUpvote() {
    if (widget.onUpvote != null) {
      setState(() {
        _isUpvoted = !_isUpvoted;
        if (_isUpvoted) {
          _isDownvoted = false;
          _upvotes++;
        } else {
          _upvotes--;
        }
      });
      widget.onUpvote!();
    }
  }

  void _handleDownvote() {
    if (widget.onDownvote != null) {
      setState(() {
        _isDownvoted = !_isDownvoted;
        if (_isDownvoted) {
          _isUpvoted = false;
          _upvotes--;
        } else {
          _upvotes++;
        }
      });
      widget.onDownvote!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.answer.isApproved
            ? colors.secondary.withOpacity(0.05)
            : colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: widget.answer.isApproved
            ? Border(
                right: BorderSide(color: colors.secondary, width: 4),
                left: BorderSide.none,
                top: BorderSide.none,
                bottom: BorderSide.none,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.answer.isApproved)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: colors.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "إجابة معتمدة",
                      style: TextStyle(
                        color: colors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colors.surfaceContainerHighest,
                  child: Icon(
                    Icons.person,
                    color: colors.onSurfaceVariant,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.answer.authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  intl.DateFormat.yMMMd().format(widget.answer.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.answer.content,
              style: TextStyle(
                fontFamily: 'Inter',
                height: 1.5,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  onTap: _handleUpvote,
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: _isUpvoted
                        ? Colors.deepOrange
                        : colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$_upvotes',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isUpvoted
                        ? Colors.deepOrange
                        : _isDownvoted
                        ? Colors.blue
                        : colors.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: _handleDownvote,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _isDownvoted ? Colors.blue : colors.onSurfaceVariant,
                  ),
                ),

                const Spacer(),

                TextButton.icon(
                  onPressed: widget.onReply,
                  icon: Icon(
                    Icons.reply_rounded,
                    size: 16,
                    color: colors.primary,
                  ),
                  label: Text("Reply", style: TextStyle(color: colors.primary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
