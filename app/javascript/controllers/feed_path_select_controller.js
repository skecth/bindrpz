import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="feed-path-select"
export default class extends Controller {
  static targets = ['feedId', 'output']
  feedPaths = {}


  connect() {
    console.log("feed-path-select")
  }
 
  handleChange() {
    const selectedFeedId = this.feedIdTarget.value;
  
    // Make an AJAX request to fetch the details of the selected feed
    fetch(`/feeds/${selectedFeedId}.json`) // Assuming the endpoint is /feeds/:id.json
      .then(response => {
        if (!response.ok) {
          throw new Error(`Network response was not ok: ${response.status}`);
        }
        return response.json();
      })
      .then(feed => {
        // Use the fetched feed data here
        console.log(`ID: ${feed.id}`);
        console.log(`Feed: ${feed.feed_path}`)
        const feedPath = `${feed.feed_path}`
        this.outputTarget.value =feedPath;


        // Update the UI with the feed details (e.g., populate other fields)
        // Example: this.updateUI(feed);
      })
      .catch(error => {
        console.error('There was a problem fetching the feed:', error);
      });

  }
}

  // handleChange(event) {
  //   const feed_id= event.target.value
  //   console.log(feed_id)
  // }
