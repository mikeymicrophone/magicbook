import { application } from "./application"
import TocEditorController from "./toc_editor_controller"
import CardRoleAssignmentController from "./card_role_assignment_controller"

application.register("toc-editor", TocEditorController)
application.register("card-role-assignment", CardRoleAssignmentController)
