From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 May 2003 00:05:15 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723705665@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 7 May 2003 17:41:08 -0600, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  Bjorn> The attached patch (against 2.4.21-rc1) makes the raw, binary
  Bjorn> error records straight from SAL available via files in /proc:

  Bjorn> 	/proc/sal/cpu<n>/{mca,init,cmc,cpe}

  Bjorn> If you read the file, you get the raw data.  If you write
  Bjorn> "clear" to it, you invalidate the current error record (which
  Bjorn> as I read the spec, may potentially make another, pending
  Bjorn> record available to be read).

Looks excellent to me, except: wouldn't you want to make this a
filesystem instead?  (Do I sound like Al Viro? ;-)

So instead of /proc/sal you'd do:

	mount -t salfs dummy /wherever

and then you'd get cpu<n>/{mca,init,cmc,cpe} in /wherever.  As of
2.5.67, we have:

	$ cat /proc/filesystems |grep nodev
	nodev   sysfs
	nodev   rootfs
	nodev   bdev
	nodev   proc
	nodev   sockfs
	nodev   usbfs
	nodev   usbdevfs
	nodev   futexfs
	nodev   tmpfs
	nodev   pipefs
	nodev   eventpollfs
	nodev   binfmt_misc
	nodev   devpts
	nodev   ramfs
	nodev   nfs
	nodev   nfs4
	nodev   nfsd
	nodev   autofs
	nodev   rpc_pipefs

So clearly there is a precedent.  Plus it would avoid all the
inefficies of /proc.

	--david

