---
title: Reliable training hack on the Google Colaboratory
author: Noon van der Silk
---

Google's
[Colaboratory](https://colab.research.google.com/notebooks/welcome.ipynb#recent=true)
is a hosted notebook environment, with access to GPUs, and even TPUs!

It's really quite handy, but by far the biggest downside is that the sessions
time out. It makes sense; I'm sure even Google can't give out an unlimited
amount of compute-resources for free to every person.

### Background/Problem

On the weekend, I wanted to train a few [sketch-rnn
models](https://github.com/tensorflow/magenta/tree/master/magenta/models/sketch_rnn)
on the [quickdraw data](https://quickdraw.withgoogle.com/data).

Naively, I figured this would be really easy with Google colab. While it was
straightforward to start training, what I noticed is that getting data on to
and off of the instance was frustrating, and the timeouts blocked me from
getting a good amoutn of training time.

### Solution

Happily, colab supports very nice integration with Google services, so my plan
was:

1. Download data from Google Cloud Platform (GCP),
2. Train, or continue training,
3. Push a checkpoint to Google Drive occasionally,
4. Repeat until happy.

Here's how it looks, in code:

**Download data from GCP**

As I'm working with the quickdraw data, it's already on the Google Cloud
Platform, so this was very easy. In a cell, I simply ran the following to get
the "eye" quickdraw data:

```
!gsutil cp gs://quickdraw_dataset/sketchrnn/eye.npz .
```

(Note that the `gsutil` command is already installed on the instance.)

**Train, or continue training, and save to Drive**

As I'm using the `sketch_rnn` model, I first simply install `magenta` (and I
have to pick a Python 2 environment.)

```
!pip install magenta
```

Now, there's some considerations. Recalling that I'm going to be pushing my
checkpoints to Google Drive, I need to authenticate with Google Drive. This
is how that looks:

``` python
from google.colab import auth
auth.authenticate_user()
```

Then you'll be prompted to copy in a code. Once that's done, you can connect
to Google Drive like so:

``` python
from googleapiclient.discovery import build
drive_service = build('drive', 'v3')
```

Now, if I'm training from scratch, I'll run something like this:

```
!sketch_rnn_train --log_root=logs --data_dir=./ --hparams="data_set=[eye.npz],num_steps=501"
```

This will run for however long, and utlimately produce checkpoints in the
`./logs` folder, supposing that `eye.npz` exists in the present directory.

Once that's completed, I start my main training-pushing loop. Firstly, there's
a bit of busywork to zip files, get the latest checkpoint number, and upload
it to Google Drive:

``` python
import os
import zipfile
from googleapiclient.http import MediaFileUpload

def get_largest_num (dir="logs", prefix="vector"):
  
  files = os.listdir(dir)
  
  biggest = 0
  
  for f in files:
    if f.startswith(prefix):
      k = int( f.split(".")[0].split("-")[1] ) 
      if k > biggest:
        biggest = k
  
  return biggest


def zip_model (name, k):
  sk     = str(k)
  zipobj = zipfile.ZipFile(name + ".zip", "w", zipfile.ZIP_DEFLATED)

  files = [ "checkpoint"
          , "model_config.json"
          , "vector-" + sk + ".meta"
          , "vector-" + sk + ".index"
          , "vector-" + sk + ".data-00000-of-00001"]
  
  for f in files:
    zipobj.write("logs/" + f, f)



def upload_to_drive (name="model.zip"):
  file_metadata = {
    "name":     name,
    "mimeType": "binary/octet-stream" }

  media = MediaFileUpload(name, 
                          mimetype="binary/octet-stream",
                          resumable=True)

  created = drive_service.files().create(body=file_metadata,
                                         media_body=media,
                                         fields="id").execute()
  file_id = created.get("id")
  return file_id
```

Then, the main loop:

``` python
iterations = 200
for k in range(iterations):
  print("Iteration " + str(k))
  cmd = 'sketch_rnn_train --log_root=logs --resume_training --data_dir=./ ' + \
        ' --hparams="data_set=[eye.npz],num_steps=1001"'
  x = os.system(cmd)
  zip_model("model", get_largest_num())
  upload_to_drive()
```

So, all that does is run the main training command, to reload the model from
the latest checkpoint and continue training, then zips and uploads!

Set the iterations to whatever you wish; chances are your instance will never
run for that long anyway; the main point is to push up the checkpoints
every-so-often (for me, every 1000 steps of the sketch_rnn model; which takes
about 1 hour or so, depending on params.)

**Brining down the most recent Drive checkpoint**

Now, when your instance goes away, you'll need to bring down the most recent
checkpoint _from_ Drive. I did this somewhat manually, but it works well
enough:

```
# Mount Google Drive as a folder
from google.colab import drive
drive.mount('/content/gdrive')
```

```
# Extract latest model zip file
!cp /content/gdrive/My\ Drive/model\ \(3\).zip logs/model.zip && cd logs && unzip model.zip
```

Note that Google Drive numbers all the files as copies, like "model (4).zip",
"model (5).zip", when you upload the same name. On the web interface, it only
shows one file, but gives you history. Do as you wish here; I was a bit lazy.


### That's it!

Hope this helps you do some training!

You can read more about other ways to access data from Google Colaboratory
[here](https://colab.research.google.com/notebooks/io.ipynb).
