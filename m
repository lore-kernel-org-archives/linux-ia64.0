From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 10 Jan 2002 19:09:57 +0000
Subject: Re: [Linux-ia64] What options to choose to get successful 2.4.4 kernel build
Message-Id: <marc-linux-ia64-105590698805791@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805765@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805765@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 7 Jan 2002 11:58:00 -0800, "Moore, Eric W" <eric.w.moore@intel.com> said:

  Eric> I am trying to compile my first Itanium kernel.  I am trying
  Eric> to compile a Linux Itanium kernel and I am having some
  Eric> difficulties.  Where could I download or copy a .configure
  Eric> file for a LION system.

The default config file *should* yield a booting kernel both for Big
Sur and Lion.  That's the intent at least (the file is in
arch/ia64/defconfig); though to be honest, it's not something I test
very frequently (but patches are always welcome).

	--david

