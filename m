From: Jim Wilson <wilson@specifixinc.com>
Date: Wed, 01 Oct 2003 22:12:51 +0000
Subject: Re: ia64_cmpxchg on United Linux 1.0
Message-Id: <marc-linux-ia64-106504643626170@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106496180632562@msgid-missing>
In-Reply-To: <marc-linux-ia64-106496180632562@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2003-09-30 at 15:38, Umut Aymakoglu wrote:
>  Is there another macro for test_and_set  that user applications
> can use?

The psABI defines a set of synchronization primitives in section 7.3. 
The psABI is available from the Intel IPF web site.
	http://developer.intel.com/design/itanium/arch_spec.htm

Gcc implements these primitives in the ia64intrin.h file.  This header
file should be available with any system that has gcc installed on it. 
It is found in the gcc install directory, probably under /usr/lib.

These are very basic primitives that expand to single IPF instructions. 
They won't be very useful unless you know what you are doing.  You might
be better off using libraries implemented on top of these primitives.

These primitives aren't used much.  HJ found a couple of simple type
errors in them when he looked at them earlier this year.  The patches
for these problems will be in gcc-3.4 which hasn't been released yet. 
They should be trivial to backpatch into older gcc releases if you need
them.
-- 
Jim Wilson, GNU Tools Support, http://www.SpecifixInc.com

