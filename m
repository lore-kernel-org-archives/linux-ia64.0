From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 06 Mar 2004 02:13:52 +0000
Subject: Re: [linux-usb-devel] Re: serious 2.6 bug in USB subsystem?
Message-Id: <16457.13280.667324.33914@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200310272235.h9RMZ9x1000602@napali.hpl.hp.com>
	<20031028013013.GA3991@kroah.com>
	<200310280300.h9S30Hkw003073@napali.hpl.hp.com>
	<3FA12A2E.4090308@pacbell.net>
	<16289.29015.81760.774530@napali.hpl.hp.com>
	<16289.55171.278494.17172@napali.hpl.hp.com>
	<3FA28C9A.5010608@pacbell.net>
	<16457.12968.365287.561596@napali.hpl.hp.com>
In-Reply-To: <16457.12968.365287.561596@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com
Cc: David Brownell <david-b@pacbell.net>, Greg KH <greg@kroah.com>, vojtech@suse.cz, linux-usb-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, pochini@shiny.it

Typo-alert:

>>>>> On Fri, 5 Mar 2004 18:08:40 -0800, David Mosberger <davidm@linux.hpl.hp.com> said:

  David>  - HCD ends up dereferencing a bad pointer and ends up
  David> reading from address 0xf0000000, which on our ia64 machines
  David> is a read-only area, which then results in a machine-check
  David> abort
              ^^^^^^^^^
              make that "write-only"

  --david
