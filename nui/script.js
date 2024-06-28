window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'openATM' || data.type === 'openBank') {
        document.getElementById('transactionMenu').style.display = 'block';
        document.getElementById('menuTitle').textContent = data.type === 'openATM' ? 'ATM' : 'Bank';
    } else if (data.type === 'close') {
        closeMenu();
    }
});

function closeMenu() {
    document.getElementById('transactionMenu').style.display = 'none';
    document.getElementById('transactionAmount').value = '';
    document.getElementById('notification').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
}

function notify(message) {
    const notification = document.getElementById('notification');
    notification.textContent = message;
    notification.style.display = 'block';
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
