From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 22 Mar 2001 05:44:46 +0000
Subject: Re: [Linux-ia64] gcc-ia64 latest distributions
Message-Id: <marc-linux-ia64-105590693005333@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005332@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005332@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 21 Mar 2001 23:50:41 -0500, "thembeka" <thembeka@bellsouth.net> said:

  thembeka> Where can I get gcc-ia64 updates? I was trying to compile
  thembeka> the linux-ia64 kernel to use with the ski simulator and
  thembeka> got an error message that the version of gcc-ia64-000216
  thembeka> (?)  was too old.

That message is wrong for IA-64.  It is removed by the IA-64 Linux
patch.  Did you apply that patch on top of the offical kernel sources?
If not, you need to do so.  It can be found at:

	ftp.kernel.org/pub/linux/kernel/ports/ia64/

  --david

