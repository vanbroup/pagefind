Feature: Word Weighting
    Background:
        Given I have the environment variables:
            | PAGEFIND_SITE | public |
        Given I have a "public/index.html" file with the body:
            """
            <p>no results</p>
            """

    Scenario: Headings are automatically favoured over standard text
        Given I have a "public/r1/index.html" file with the body:
            """
            <p>Antelope</p>
            <p>Antelope Antelope Antelope Antelope</p>
            <p>Other text again</p>
            """
        Given I have a "public/r2/index.html" file with the body:
            """
            <p>Antelope</p>
            <p>Antelope Antelope Antelope</p>
            <p>Other text again</p>
            """
        Given I have a "public/r3/index.html" file with the body:
            """
            <h6>Antelope</h6>
            <p>Antelope Antelope Antelope</p>
            <p>Other text again</p>
            """
        Given I have a "public/r4/index.html" file with the body:
            """
            <h1>Antelope</h1>
            <p>Other text</p>
            """
        Given I have a "public/r5/index.html" file with the body:
            """
            <h2>Antelope</h2>
            <p>Other text again</p>
            """
        When I run my program
        Then I should see "Running Pagefind" in stdout
        When I serve the "public" directory
        When I load "/"
        When I evaluate:
            """
            async function() {
                let pagefind = await import("/pagefind/pagefind.js");

                let search = await pagefind.search(`antelope`);

                let data = await Promise.all(search.results.map(result => result.data()));
                document.querySelector('p').innerText = data.map(d => d.url).join(', ');
            }
            """
        Then There should be no logs
        Then The selector "p" should contain "/r4/, /r5/, /r3/, /r1/, /r2/"

    Scenario: Text can be explicitly weighted higher
        Given I have a "public/r1/index.html" file with the body:
            """
            <p>Antelope</p>
            <p>Antelope Antelope Not</p>
            """
        Given I have a "public/r2/index.html" file with the body:
            """
            <p>Antelope</p>
            <p>Antelope Not</p>
            """
        Given I have a "public/r3/index.html" file with the body:
            """
            <p data-pagefind-weight="3">Antelope</p>
            <p>Antelope Not</p>
            """
        Given I have a "public/r4/index.html" file with the body:
            """
            <p>Antelope</p>
            <p>Antelope Antelope Antelope Antelope</p>
            """
        When I run my program
        Then I should see "Running Pagefind" in stdout
        When I serve the "public" directory
        When I load "/"
        When I evaluate:
            """
            async function() {
                let pagefind = await import("/pagefind/pagefind.js");

                let search = await pagefind.search(`antelope`);

                let data = await Promise.all(search.results.map(result => result.data()));
                document.querySelector('p').innerText = data.map(d => d.url).join(', ');
            }
            """
        Then There should be no logs
        Then The selector "p" should contain "/r3/, /r4/, /r1/, /r2/"

    Scenario: Text can be explicitly weighted lower
        Given I have a "public/r1/index.html" file with the body:
            """
            <p data-pagefind-weight="0.1">Antelope Antelope all about Antelope</p>
            <p>More text about other stuff</p>
            """
        Given I have a "public/r2/index.html" file with the body:
            """
            <p>Five words that aren't related</p>
            <p>One solitary mention of antelope</p>
            """
        When I run my program
        Then I should see "Running Pagefind" in stdout
        When I serve the "public" directory
        When I load "/"
        When I evaluate:
            """
            async function() {
                let pagefind = await import("/pagefind/pagefind.js");

                let search = await pagefind.search(`antelope`);

                let data = await Promise.all(search.results.map(result => result.data()));
                document.querySelector('p').innerText = data.map(d => d.url).join(', ');
            }
            """
        Then There should be no logs
        Then The selector "p" should contain "/r2/, /r1/"

    Scenario: Compound words are implicitly weighted lower
        Given I have a "public/r1/index.html" file with the body:
            """
            <p>A single reference to antelope</p>
            """
        Given I have a "public/r2/index.html" file with the body:
            """
            <p>Two references to ThreeWordAntelope ThreeWordAntelope</p>
            """
        Given I have a "public/r3/index.html" file with the body:
            """
            <p>Three of TwoAntelope TwoAntelope TwoAntelope</p>
            """
        When I run my program
        Then I should see "Running Pagefind" in stdout
        When I serve the "public" directory
        When I load "/"
        When I evaluate:
            """
            async function() {
                let pagefind = await import("/pagefind/pagefind.js");

                let search = await pagefind.search(`antelope`);

                let data = await Promise.all(search.results.map(result => result.data()));
                document.querySelector('p').innerText = data.map(d => d.url).join(', ');
            }
            """
        Then There should be no logs
        Then The selector "p" should contain "/r3/, /r1/, /r2/"
