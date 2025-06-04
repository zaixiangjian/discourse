import Component from "@glimmer/component";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

export default class TopicStatusColumn extends Component {
  @service siteSettings;

  get badge() {
    if (this.args.topic.is_hot) {
      return {
        icon: "fire",
        text: "topic_hot",
        className: "--hot",
      };
    }

    if (this.args.topic.pinned) {
      return {
        icon: "thumbtack",
        text: "topic_pinned",
        className: "--pinned",
      };
    }

    return null;
  }

  <template>
    {{#if this.badge}}
      <span class="topic-status-card {{this.badge.className}}">{{icon
          this.badge.icon
        }}{{i18n (themePrefix this.badge.text)}}</span>
    {{/if}}
  </template>
}
