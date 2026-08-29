import { application } from "./application"
import TocEditorController from "./toc_editor_controller"
import CardRoleAssignmentController from "./card_role_assignment_controller"
import ApplyExistingTagController from "./apply_existing_tag_controller"
import CreateTagController from "./create_tag_controller"
import ListedItemAdderController from "./listed_item_adder_controller"
import TaggingPanelController from "./tagging_panel_controller"
import TaggingDisclosureController from "./tagging_disclosure_controller"
import StyleColorController from "./style_color_controller"

application.register("toc-editor", TocEditorController)
application.register("card-role-assignment", CardRoleAssignmentController)
application.register("apply-existing-tag", ApplyExistingTagController)
application.register("create-tag", CreateTagController)
application.register("listed-item-adder", ListedItemAdderController)
application.register("tagging-panel", TaggingPanelController)
application.register("tagging-disclosure", TaggingDisclosureController)
application.register("style-color", StyleColorController)
