From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 14 Feb 2001 20:35:52 +0000
Subject: Re: [Linux-ia64] 2.4.1 network problems
Message-Id: <marc-linux-ia64-105590693005150@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005146@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005146@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 Feb 2001 12:10:24 -0800, Michael Madore <mmadore@turbolinux.com> said:

  Mike> In addition to the >1024MB problem, I am also experiencing a
  Mike> reproducible nfs hang on Lions.  If I copy this file

  Mike>    ftp://frontier.turbolinux.com/pub/ia64/nfshang.bin

  Mike> from an nfs server to the local file system, the copy hangs
  Mike> after transferring 294912 bytes.  If I copy the file from the
  Mike> local filesystem to the server, the copy completes
  Mike> successfully.  The hang only occurs with certain files.

That's a rather bizarre bug.  I can confirm this is happening on one
of our Lions as well.  The Big Sur (also with eepro100) is fine
though.  The Lion has 4GB and the Big Sur only 1GB of RAM.

Thanks,

	--david

