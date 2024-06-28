window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'openATM' || data.type === 'openBank') {
        openMenu(data.type === 'openATM' ? 'ATM' : 'Bank');
    } else if (data.type === 'close') {
        closeMenu();
    } else if (data.type === 'error') {
        showError(data.message);
    } else if (data.type === 'success') {
        showSuccess(data.message);
    }
});

function openMenu(title) {
    document.getElementById('transactionMenu').style.display = 'block';
    document.getElementById('menuTitle').textContent = title;
    playSound('open');
}

function closeMenu() {
    document.getElementById('transactionMenu').style.display = 'none';
    document.getElementById('transactionAmount').value = '';
    document.getElementById('notification').style.display = 'none';
    document.getElementById('error').style.display = 'none';
    document.getElementById('success').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
}

function showError(message) {
    const errorElement = document.getElementById('error');
    errorElement.textContent = message;
    errorElement.style.display = 'block';
    setTimeout(() => {
        errorElement.style.display = 'none';
    }, 5000);
}

function showSuccess(message) {
    const successElement = document.getElementById('success');
    successElement.textContent = message;
    successElement.style.display = 'block';
    setTimeout(() => {
        successElement.style.display = 'none';
    }, 5000);
}

function deposit() {
    const amount = parseFloat(document.getElementById('transactionAmount').value);
    if (!isNaN(amount)) {
        fetch(`https://${GetParentResourceName()}/deposit`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ amount })
        });
    } else {
        showError('Invalid amount entered.');
    }
}

function withdraw() {
    const amount = parseFloat(document.getElementById('transactionAmount').value);
    if (!isNaN(amount)) {
        fetch(`https://${GetParentResourceName()}/withdraw`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({ amount })
        });
    } else {
        showError('Invalid amount entered.');
    }
}

function playSound(type) {
    let sound;
    switch(type) {
        case 'open':
            sound = new Audio('sounds/open.mp3');
            break;
        case 'close':
            sound = new Audio('sounds/close.mp3');
            break;
        case 'error':
            sound = new Audio('sounds/error.mp3');
            break;
        case 'success':
            sound = new Audio('sounds/success.mp3');
            break;
    }
    if (sound) {
        sound.play();
    }
}
