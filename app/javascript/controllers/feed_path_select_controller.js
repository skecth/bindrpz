import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="feed-path-select"
export default class extends Controller {
  static targets = ['feedId', 'output', 'zone']
  feedPaths = {}


  connect() {
    console.log("feed-path-select");
    // Assign value to zoneName property
  }

  handleChange() {
    //show feed id
    const selectedFeedId = this.feedIdTarget.value;
    const zoneName =this.zoneTarget.value;
    console.log(`selected: ${selectedFeedId}`)
    console.log(zoneName);
    // Make an AJAX request to fetch the details of the selected feed
    const jsonArray = `/feeds/${selectedFeedId}.json`
    fetch(jsonArray) // Assuming the endpoint is /feeds/:id.json
      .then(response => {
        if (!response.ok) {
          throw new Error(`Network response was not ok: ${response.status}`);
        }
        return response.json();
      })
      .then(feedData => {
        // Use the fetched feed data here
        const lastObject = feedData[feedData.length - 1];

    // Check if the last object has "id" and "feed_name" properties
    if (lastObject && lastObject.hasOwnProperty('id') && lastObject.hasOwnProperty('feed_name')) {
      // Extract "id" and "feed_name"
      const id = lastObject.id;
      const feedName = lastObject.feed_name;

      // Log the values
      console.log(`ID: ${id}`);
      console.log(`Feed Name: ${feedName}`);
      const feedPath = `/etc/bind/${zoneName}/${feedName}.rpzfeed`
        console.log(feedPath)
        this.outputTarget.value =feedPath;
    } else {
      console.log("The last object does not have 'id' and 'feed_name' properties.");
    }

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
