From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 17 May 2001 14:59:14 +0000
Subject: Re: [Linux-ia64] NFS v3 server
Message-Id: <marc-linux-ia64-105590693005603@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005598@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005598@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 17 May 2001 16:58:19 +0900, Hiroshi Aono <aono@hpc.bs1.fc.nec.co.jp> said:

  Hiroshi> Hello everyone, I've tried to work NFS v3 server on Bigsur,
  Hiroshi> but it doesn't work.  When mounting with NFS v3, the mount
  Hiroshi> command says NFSv3 not supported!

  Hiroshi> Anyone tried to use the NFS v3 server on ia64 linux?

  Hiroshi> The kernel version is 2.4.4.

There is a 64-bit fix for NFS v3 in 2.4.5-pre3.  Haven't tried it
myself, though.

	--david

