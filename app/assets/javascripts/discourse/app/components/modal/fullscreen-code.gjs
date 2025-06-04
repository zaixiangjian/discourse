import Component from "@glimmer/component";
import AceEditor from "discourse/components/ace-editor";
import DModal from "discourse/components/d-modal";
import { i18n } from "discourse-i18n";
import HighlightedCode from "admin/components/highlighted-code";

export default class FullscreenCode extends Component {
  <template>
    <DModal
      @title={{i18n "copy_codeblock.view_code"}}
      @closeModal={{@closeModal}}
      class="fullscreen-code-modal -max"
    >
      <:body>
        <HighlightedCode @lang={{@model.lang}} @code={{@model.code}} />
      </:body>
    </DModal>
  </template>
}
