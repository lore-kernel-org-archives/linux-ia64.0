From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 20 Aug 2003 04:01:50 +0000
Subject: Re: generic kernel on the simulator
Message-Id: <marc-linux-ia64-106135212320314@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106134305414419@msgid-missing>
In-Reply-To: <marc-linux-ia64-106134305414419@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 20 Aug 2003 11:24:14 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:

  Ian> Hi, Should a generic kernel be able to boot on the simulator?
  Ian> The kernel seems to build in machine vector information for the
  Ian> simulator, but I'm not sure if the simulator simulates enough
  Ian> for the init routines to discover this?

I think it would be useful to have that work because it would mean
that anyone with access to real hardware could test at least two very
different platforms with a generic kernel (namely Ski and the real
hardware).

I suspect we'll need to add some more fw emulation to make this really
work.  Actually, looking at acpi_get_sysname(), perhaps we just need
to change it so that if the rsdp cannot be found, we default to hpsim?
Without RSDP, real hardware won't be able to boot anyhow, so returning
"dig" makes little sense.

	--david
