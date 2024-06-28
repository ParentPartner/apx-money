window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'openATM' || data.type === 'openBank') {
        openMenu(data.type === 'openATM' ? 'ATM' : 'Bank');
    } else if (data.type === 'close') {
        closeMenu();
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
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
    playSound('close');
}

function notify(message) {
    const notification = document.getElementById('notification');
    notification.textContent = message;
    notification.style.display = 'block';
    playSound('error');
    setTimeout(() => {
        notification.style.display = 'none';
    }, 3000);
}

function deposit() {
    const amount = parseFloat(document.getElementById('transactionAmount').value);
    if (isNaN(amount) || amount <= 0) {
        notify("You cannot deposit $0 or less.");
        return;
    }
    fetch(`https://${GetParentResourceName()}/deposit`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ amount }),
    }).then(() => {
        closeMenu();
    });
}

function withdraw() {
    const amount = parseFloat(document.getElementById('transactionAmount').value);
    if (isNaN(amount) || amount <= 0) {
        notify("You cannot withdraw $0 or less.");
        return;
    }
    fetch(`https://${GetParentResourceName()}/withdraw`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ amount }),
    }).then(() => {
        closeMenu();
    });
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
    }
    if (sound) {
        sound.play();
    }
}
