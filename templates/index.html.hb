    {{#each recent_entries }}
        <h2><a href="/{{ this.slug }}/">{{ this.title }}</a></h2>
        <h6>posted {{ this.date }} by  <a href="/about/">Ben Cordero</a>.</h6>
        content goes here
        <div>
            <p><a href="/{{ this.slug }}/">Read more</a></p>
        </div>
    {{/each}}
