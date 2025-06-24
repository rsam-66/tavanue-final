const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.decrementPlantDays = functions.pubsub
  .schedule("0 2 * * *") // ⏰ every day at 02:00 WIB
  .timeZone("Asia/Jakarta")
  .onRun(async () => {
    console.log("Running daily decrement...");

    const snapshot = await db.collection("tanaman").get();

    const updates = snapshot.docs.map(async (doc) => {
      const data = doc.data();
      let hari = parseInt((data.sisaHari && data.sisaHari.replace(/\D/g, "")) || "0");
      let bulan = parseInt((data.sisaBulan && data.sisaBulan.replace(/\D/g, "")) || "0");

      // Already expired or marked as harvested
      if (data.sisaHari === "Panen Hari Ini! Cek Tanaman Kamu!") return;

      // Main decrement logic
      if (hari > 0) {
        hari -= 1;
      } else if (bulan > 0) {
        bulan -= 1;
        hari = 30;
      }

      // Handle harvest case
      if (hari === 0 && bulan === 0) {
        return doc.ref.update({
          sisaHari: "Panen Hari Ini! Cek Tanaman Kamu!",
          sisaBulan: "",
          status: "readyToHarvest"
        });
      }

      else if (bulan === 0) {
        return doc.ref.update({
          sisaHari: `${hari} Hari`,
          sisaBulan: "",
        });
      }

      // Otherwise, update as usual
      return doc.ref.update({
        sisaHari: `${hari} Hari`,
        sisaBulan: `${bulan} Bulan`,
      });
    });

    await Promise.all(updates);
    console.log("Decrement complete.");
  });
