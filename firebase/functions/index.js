const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
admin.firestore().settings({ timestampsInSnapshots: true });
exports.createUser = functions.auth.user().onCreate((user, context) => {
    const uid = user.uid;

    return admin.firestore().collection('groups').listDocuments().then((documents) => {
        const doc = documents[0];

        return admin.firestore().collection('users').doc(user.uid).set({
            'uid': uid,
            'group': doc,
            'challenges': [
                '1mNPOKsVDHds5cCQcila',
                'Wis8WFGQeCFbwcnGGzGC'
            ]
        }, { 
            merge: true
        });
    }).then((_) => {
        return Promise.all([
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'pushups',
                'date': new Date('March 5, 2019'),
                'amount': 12,
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'pushups',
                'date': new Date('March 1, 2019'),
                'amount': 5
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'pushups',
                'date': new Date('March 2, 2019'),
                'amount': 10
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'pushups',
                'date': new Date('March 4, 2019'),
                'amount': 8
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'pushups',
                'date': new Date('March 7, 2019'),
                'amount': 20
            }),
        ]);
    }).then((_) => {
        return Promise.all([
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'running',
                'date': new Date('March 1, 2019'),
                'amount': 1
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'running',
                'date': new Date('March 2, 2019'),
                'amount': 3
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'running',
                'date': new Date('March 4, 2019'),
                'amount': 6
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'running',
                'date': new Date('March 5, 2019'),
                'amount': 2,
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'running',
                'date': new Date('March 7, 2019'),
                'amount': 9
            }),
        ]);
    }).then((_) => {
        return Promise.all([
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'lunges',
                'date': new Date('March 1, 2019'),
                'amount': 32
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'lunges',
                'date': new Date('March 2, 2019'),
                'amount': 45
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'lunges',
                'date': new Date('March 4, 2019'),
                'amount': 13
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'lunges',
                'date': new Date('March 5, 2019'),
                'amount': 56,
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'lunges',
                'date': new Date('March 7, 2019'),
                'amount': 95
            }),
        ]);
    }).then((_) => {
        return Promise.all([
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'benchpress',
                'date': new Date('March 1, 2019'),
                'amount': 25
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'benchpress',
                'date': new Date('March 2, 2019'),
                'amount': 50
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'benchpress',
                'date': new Date('March 4, 2019'),
                'amount': 25
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'benchpress',
                'date': new Date('March 5, 2019'),
                'amount': 100,
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'benchpress',
                'date': new Date('March 7, 2019'),
                'amount': 250
            }),
        ]);
    }).then((_) => {
        return Promise.all([
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'squats',
                'date': new Date('March 1, 2019'),
                'amount': 30
            }),
            admin.firestore().collection('activity').add({
                'uid': uid,
                'activity': 'squats',
                'date': new Date('March 2, 2019'),
                'amount': 50
            }),
        ]);
    });
});
