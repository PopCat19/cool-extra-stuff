document.addEventListener('DOMContentLoaded', function() {
    const select = document.getElementById('game-select');
    const selected = select.querySelector('.select-selected');
    const items = select.querySelector('.select-items');
    const queryInput = document.getElementById('query-input');
    const customGameInput = document.getElementById('custom-game-input');
    let currentIndex = -1; // keep track of the currently selected item

    // Store the list items in an array for consistent navigation
    const itemsArray = Array.prototype.slice.call(items.children);

    // Function to navigate to an item in the dropdown
    function navigateToItem(index) {
        const selectedItem = itemsArray[index];
        selected.textContent = selectedItem.textContent;
        selected.dataset.value = selectedItem.dataset.value;

        // Show custom game input if "Other" is selected
        const customGameField = document.getElementById('custom-game-field');
        if (selected.dataset.value === 'other') {
            customGameField.style.display = 'block';
            customGameInput.focus(); // Autofocus custom game input
        } else {
            customGameField.style.display = 'none';
            queryInput.focus(); // Autofocus query input
        }

        // Save the last selection
        saveLastSelection();
    }

    // Function to perform search
    function performSearch() {
        const gameSelect = document.getElementById('game-select');
        const selected = gameSelect.querySelector('.select-selected');
        const game = selected.dataset.value === 'other' ? document.getElementById('custom-game-input').value.trim() : selected.dataset.value;
        const query = queryInput.value.trim();

        if (game) {
            const queries = query ? query.split(',').map(q => q.trim()) : [''];
            queries.forEach(q => {
                const encodedGame = encodeURIComponent(game);
                const encodedQuery = encodeURIComponent(q);
                const url = `https://game8.co/games/${encodedGame}/search?q=${encodedQuery}`;
                console.log(`Opening URL: ${url}`);
                chrome.tabs.create({ url: url });
            });
        } else {
            alert('Please enter a game name.');
        }
    }

    // Function to save the last selection
    function saveLastSelection() {
        const selected = document.getElementById('game-select').querySelector('.select-selected');
        localStorage.setItem('lastSelection', selected.dataset.value);
        if (selected.dataset.value === 'other') {
            localStorage.setItem('customGame', customGameInput.value.trim());
        }
    }

    // Function to load the last selection
    function loadLastSelection() {
        const lastSelection = localStorage.getItem('lastSelection');
        if (lastSelection) {
            const selectedItem = itemsArray.find(item => item.dataset.value === lastSelection);
            if (selectedItem) {
                selected.textContent = selectedItem.textContent;
                selected.dataset.value = selectedItem.dataset.value;
                if (lastSelection === 'other') {
                    const customGame = localStorage.getItem('customGame');
                    if (customGame) {
                        customGameInput.value = customGame;
                        document.getElementById('custom-game-field').style.display = 'block';
                        customGameInput.focus(); // Autofocus custom game input
                    } else {
                        document.getElementById('custom-game-field').style.display = 'block';
                        customGameInput.focus(); // Autofocus custom game input
                    }
                } else {
                    document.getElementById('custom-game-field').style.display = 'none';
                    queryInput.focus(); // Autofocus query input
                }
            }
        }
    }

    // Load the last selection
    loadLastSelection();

    // Event listener for dropdown selection
    selected.addEventListener('click', function() {
        items.classList.toggle('select-hide');
        items.classList.toggle('select-show');
        queryInput.focus(); // Focus the query input when the dropdown is shown
    });

    // Event listener for item selection
    items.addEventListener('click', function(event) {
        if (event.target.tagName === 'DIV') {
            selected.textContent = event.target.textContent;
            selected.dataset.value = event.target.dataset.value;
            items.classList.remove('select-show');
            items.classList.add('select-hide');
            // Show custom game input if "Other" is selected
            const customGameField = document.getElementById('custom-game-field');
            if (selected.dataset.value === 'other') {
                customGameField.style.display = 'block';
                customGameInput.focus(); // Autofocus custom game input
            } else {
                customGameField.style.display = 'none';
                queryInput.focus(); // Autofocus query input
            }
            // Save the last selection
            saveLastSelection();
        }
    });

    // Event listener to hide dropdown when clicking elsewhere
    document.addEventListener('click', function(event) {
        if (!select.contains(event.target) && !items.contains(event.target)) {
            items.classList.remove('select-show');
            items.classList.add('select-hide');
        }
    });

    // Event listener for search input
    queryInput.tabIndex = 0; // Make the input element focusable
    queryInput.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            performSearch();
        }
    });

    // Get the search button
    const searchButton = document.getElementById('search-button');

    // Add an event listener to the search button
    searchButton.addEventListener('click', performSearch);

    // Add event listener for arrow keys to cycle through items
    document.addEventListener('keydown', function(event) {
        if (event.key === 'ArrowDown') {
            currentIndex = (currentIndex + 1) % itemsArray.length;
            navigateToItem(currentIndex);
        } else if (event.key === 'ArrowUp') {
            currentIndex = (currentIndex - 1 + itemsArray.length) % itemsArray.length;
            navigateToItem(currentIndex);
        }
    });

    // Event listener for custom game input to save its value and autofocus query input on Enter
    customGameInput.addEventListener('input', function() {
        localStorage.setItem('customGame', customGameInput.value.trim());
    });

    customGameInput.addEventListener('keypress', function(event) {
        if (event.key === 'Enter') {
            queryInput.focus(); // Autofocus query input
        }
    });

    const inputField = document.getElementById('input-field');

    inputField.addEventListener('click', function(event) {
        event.preventDefault();
    });

    const container = document.querySelector('.custom-select-container');

    container.addEventListener('mouseover', function() {
        container.style.transition = 'opacity 0.1s ease-in';
        container.style.opacity = '0.8';
    });

    container.addEventListener('mouseout', function() {
        container.style.transition = 'opacity 0.1s ease-out';
        container.style.opacity = '1';
    });
});
