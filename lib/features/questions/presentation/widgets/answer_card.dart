import 'package:dalleni/core/providers/core_providers.dart';
import 'package:dalleni/features/questions/presentation/widgets/common_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/theme/dalleni_theme.dart';
import '../../domain/entities/question_entity.dart';
import '../providers/question_details_controller.dart';

class AnswerCard extends ConsumerStatefulWidget {
  const AnswerCard({
    super.key,
    required this.answer,
    required this.questionId,
    required this.questionuserId,
  });

  final Answer answer;
  final String questionId;
  final String questionuserId;

  @override
  ConsumerState<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends ConsumerState<AnswerCard> {
  bool _isUpvoted = false;
  bool _isDownvoted = false;

  bool _isQuestionOwner = false;
  bool _isCheckingOwner = true;

  late int _upvotes;

  @override
  void initState() {
    super.initState();

    debugPrint('AnswerCard CREATED: ${widget.answer.id}');

    _upvotes = widget.answer.upvotes;
    _checkQuestionOwner();
  }

  @override
  void dispose() {
    debugPrint('AnswerCard DISPOSED: ${widget.answer.id}');
    super.dispose();
  }

  Future<void> _checkQuestionOwner() async {
    final localStorage = ref.read(localStorageServiceProvider);
    final currentUserId = localStorage.getUserId();

    if (!mounted) return;

    setState(() {
      _isQuestionOwner = currentUserId == widget.questionuserId;
      _isCheckingOwner = false;
    });
  }

  void _handleUpvote() {
    final controller = ref.read(
      questionDetailsControllerProvider(widget.questionId).notifier,
    );

    setState(() {
      if (_isUpvoted) {
        _isUpvoted = false;
        _upvotes--;
      } else {
        _isUpvoted = true;

        if (_isDownvoted) {
          _isDownvoted = false;
          _upvotes++;
        } else {
          _upvotes++;
        }
      }
    });

    controller.upvoteAnswer(widget.answer.id);
  }

  void _handleDownvote() {
    final controller = ref.read(
      questionDetailsControllerProvider(widget.questionId).notifier,
    );

    setState(() {
      if (_isDownvoted) {
        _isDownvoted = false;
        _upvotes++;
      } else {
        _isDownvoted = true;

        if (_isUpvoted) {
          _isUpvoted = false;
          _upvotes--;
        } else {
          _upvotes--;
        }
      }
    });

    controller.downvoteAnswer(widget.answer.id);
  }

  void _handleDelete() {
    final controller = ref.read(
      questionDetailsControllerProvider(widget.questionId).notifier,
    );

    controller.deleteComment(widget.answer.id);
  }

  void _handleAccept() {
    final controller = ref.read(
      questionDetailsControllerProvider(widget.questionId).notifier,
    );

    controller.toggleAcceptAnswer(
      answerId: widget.answer.id,
      isAccepted: widget.answer.isApproved,
    );
  }

  void _handleMark(bool isMarked) {
    final newMarkedState = !isMarked;

    debugPrint('isMarked: $isMarked');
    debugPrint('newMarkedState: $newMarkedState');

    ref
        .read(questionDetailsControllerProvider(widget.questionId).notifier)
        .toggleMarkAnswer(
          answerId: widget.answer.id,
          shouldMark: newMarkedState,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dalleniColors;

    final isMarked = ref.watch(
      questionDetailsControllerProvider(
        widget.questionId,
      ).select((state) => state.markedAnswers[widget.answer.id] ?? false),
    );

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.surfaceContainerHighest,
                child: Icon(
                  Icons.person,
                  color: colors.onSurfaceVariant,
                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.answer.authorName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            widget.answer.content,
                            style: TextStyle(
                              color: colors.onSurface,
                              height: 1.45,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          Text(
                            intl.DateFormat.MMMd().format(
                              widget.answer.timestamp,
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(width: 12),

                          CommentAction(
                            label: 'Upvote',
                            isActive: _isUpvoted,
                            activeColor: Colors.deepOrange,
                            onTap: _handleUpvote,
                          ),

                          const SizedBox(width: 12),

                          CommentAction(
                            label: 'Downvote',
                            isActive: _isDownvoted,
                            activeColor: Colors.blue,
                            onTap: _handleDownvote,
                          ),

                          const SizedBox(width: 12),

                          CommentAction(
                            label: 'Delete',
                            isActive: false,
                            activeColor: colors.error,
                            onTap: _handleDelete,
                          ),

                          if (!_isCheckingOwner && _isQuestionOwner) ...[
                            const SizedBox(width: 12),

                            CommentAction(
                              label: widget.answer.isApproved
                                  ? 'Unaccept'
                                  : 'Accept',
                              isActive: widget.answer.isApproved,
                              activeColor: colors.secondary,
                              onTap: _handleAccept,
                            ),
                          ] else ...[
                            const SizedBox(width: 12),

                            CommentAction(
                              label: isMarked ? 'Unmark' : 'Mark',
                              isActive: isMarked,
                              activeColor: colors.secondary,
                              onTap: () => _handleMark(isMarked),
                            ),
                          ],

                          const Spacer(),

                          if (widget.answer.isApproved)
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 15,
                                  color: colors.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Approved',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colors.secondary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    if (_upvotes != 0) ...[
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(Icons.thumb_up, size: 13, color: colors.primary),

                          const SizedBox(width: 4),

                          Text(
                            '$_upvotes',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Divider(height: 1, color: colors.outlineVariant),
        ],
      ),
    );
  }
}
