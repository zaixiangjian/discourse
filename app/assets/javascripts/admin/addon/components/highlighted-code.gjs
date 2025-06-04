import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import concatClass from "discourse/helpers/concat-class";
import highlightSyntax from "discourse/lib/highlight-syntax";

class FadeOutLayer extends Component {
  <template>
    <AuxiliaryLayer
      @lineNumbers={{@lineNumbers}}
      @highlightedLines={{@highlightedLines}}
      ...attributes
    >&nbsp;</AuxiliaryLayer>
  </template>
}

class NumbersLayer extends Component {
  <template>
    <AuxiliaryLayer
      @lineNumbers={{@lineNumbers}}
      @highlightedLines={{@highlightedLines}}
      ...attributes
      as |ln|
    ><span class="number">{{ln}}</span></AuxiliaryLayer>
  </template>
}

class BackgroundLayer extends Component {
  <template>
    <AuxiliaryLayer
      @lineNumbers={{@lineNumbers}}
      @highlightedLines={{@highlightedLines}}
      ...attributes
    >&nbsp;</AuxiliaryLayer>
  </template>
}

class AuxiliaryLayer extends Component {
  newline = "\n";

  @action
  isHighlightedLine(ln) {
    return this.args.highlightedLines && this.args.highlightedLines.has(ln);
  }

  <template>
    <pre aria-hidden={{true}} ...attributes>{{~#each @lineNumbers as |ln|}}<span
          class={{concatClass
            "highlighted-code__line-placeholder"
            (if (this.isHighlightedLine ln) "-highlighted" "-not-highlighted ")
          }}
        >{{yield ln}}</span>{{this.newline}}{{/each~}}</pre>
  </template>
}

export default class HighlightedCode extends Component {
  @service session;
  @service siteSettings;

  highlight = modifier(async (element) => {
    const code = document.createElement("code");
    code.classList.add(`lang-${this.args.lang}`);
    code.textContent = this.args.code;

    element.replaceChildren(code);
    await highlightSyntax(element, this.siteSettings, this.session);
  });

  get lineNumbers() {
    return this.args.code.split("\n").map((_, index) => index + 1);
  }

  get highlightedLines() {
    return this.parseLineRanges("1, 3-4");
  }

  @action
  parseLineRanges(lineRangesRaw) {
    if (lineRangesRaw === undefined) {
      return null;
    }

    return new Set(lineRangesRaw.split(",").flatMap(this.parseLineRange));
  }

  @action
  parseLineRange(lineRangeRaw) {
    let [begin, end] = lineRangeRaw.trim().split("-");
    if (!end) {
      end = begin;
    }

    return this.range(Number(begin), Number(end) + 1);
  }

  range(start, end) {
    const result = [];
    for (let i = start; i < end; i++) {
      result.push(i);
    }
    return result;
  }

  <template>
    <div class="highlighted-code --with-line-highlighting --with-line-numbers">
      <BackgroundLayer
        @lineNumbers={{this.lineNumbers}}
        @highlightedLines={{this.highlightedLines}}
        class="highlighted-code__background-layer"
      />

      <pre {{this.highlight}} class="highlighted-code__code"></pre>

      {{#if this.highlightedLines}}
        <NumbersLayer
          @lineNumbers={{this.lineNumbers}}
          class="highlighted-code__numbers-layer"
        />
      {{/if}}
    </div>
  </template>
}
