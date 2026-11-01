const mongoose = require('mongoose');

const imageRefSchema = new mongoose.Schema(
  {
    itemId: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    category: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    englishLabel: {
      type: String,
      required: true,
      trim: true,
    },
    urduLabel: {
      type: String,
      required: true,
      trim: true,
    },
    sourceType: {
      type: String,
      enum: ['local', 'remote'],
      required: true,
    },
    assetPath: {
      type: String,
      trim: true,
    },
    remoteUrl: {
      type: String,
      trim: true,
    },
    attributionNote: {
      type: String,
      trim: true,
    },
  },
  {
    timestamps: true,
    collection: 'image_refs',
  },
);

imageRefSchema.index({ category: 1, itemId: 1 }, { unique: true });

imageRefSchema.pre('validate', async function () {
  if (this.sourceType === 'local' && !this.assetPath) {
    throw new Error('assetPath is required when sourceType is "local"');
  }
  if (this.sourceType === 'remote' && !this.remoteUrl) {
    throw new Error('remoteUrl is required when sourceType is "remote"');
  }
});

const ImageRef = mongoose.models.ImageRef || mongoose.model('ImageRef', imageRefSchema);

module.exports = { ImageRef };
