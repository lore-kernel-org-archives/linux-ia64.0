From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 08 Feb 2000 18:39:15 +0000
Subject: Re: [Linux-ia64] booting? or is this list dead? ;-)
Message-Id: <marc-linux-ia64-105590678204918@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204916@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204916@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 8 Feb 2000 00:41:15 -0800 (PST), Goutham Rao <goutham.rao@intel.com> said:

  Goutham> It will depend on your system configuration... if all you
  Goutham> have on IDE is the ls120 and CD, then I think the CD would
  Goutham> be /dev/hdc so you should be able to use "eli <vmlinux>
  Goutham> root=/dev/hdc"

Don't forget to specify the "rescue" option---otherwise, the boot will
get stuck halfway through.  Unfortunately, I wasn't able to document
this option in README.IA-64 because I didn't know if the CD-ROM is
actually bootable until we had the master (and then it was too late to
update the README and make a new master...).

	--david


