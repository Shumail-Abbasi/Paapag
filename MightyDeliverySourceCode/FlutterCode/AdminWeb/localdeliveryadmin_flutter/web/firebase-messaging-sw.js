importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js');

   /*Update with yours config*/
 const firebaseConfig = {
   apiKey: "AIzaSyBNfqjs4no9jb_15Nf8Dx4Q5_ZCrurHmvs",
   authDomain: "paapag-2c755.firebaseapp.com",
   projectId: "paapag-2c755",
   storageBucket: "paapag-2c755.appspot.com",
   messagingSenderId: "115794562052",
   appId: "1:115794562052:web:c97997c34d05c55acb7951",
   measurementId: "G-MWPPYDLTMR"
 };
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });