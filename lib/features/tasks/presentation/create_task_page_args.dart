import '../domain/entities/task_entity.dart';
import '../../teams/domain/entities/team_entity.dart';

/// Route arguments passed to [CreateTaskPage] to control which mode it opens in.
///
/// - Provide [presetTeam] to pre-select a team (e.g. when opening from
///   Team Details so the user does not have to pick the team manually).
/// - Provide [draftTask] to open the form in edit-draft mode, pre-filling all
///   fields from an existing draft so the user can update or publish it.
/// - Omit both to open in plain new-task mode.
class CreateTaskPageArgs {
  /// The team to pre-select in the team picker.
  final TeamEntity? presetTeam;

  /// The existing draft to edit. When non-null, the page operates in
  /// edit-draft mode and its action buttons change to
  /// "Save Draft Changes" / "Publish Task".
  final TaskEntity? draftTask;

  /// The existing active task to edit. When non-null, the page operates in
  /// edit-active-task mode and its action button changes to "Save Changes".
  final TaskEntity? activeTaskToEdit;

  const CreateTaskPageArgs({
    this.presetTeam,
    this.draftTask,
    this.activeTaskToEdit,
  });
}
