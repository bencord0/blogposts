    {{#each recent_entries }}
        <h2><a href="/{{ slug }}/">{{ title }}</a></h2>
        <h6>posted {{ date }} by  <a href="/about/">Ben Cordero</a>.</h6>
        content goes here
        <div>
            <p><a href="/{{ slug }}/">Read more</a></p>
        </div>
    {{/each}}
