From: Ashok Raj <ashok.raj@intel.com>
Date: Wed, 23 Mar 2005 22:57:39 +0000
Subject: Re: [PATCH] User Level Interrupts
Message-Id: <20050323145738.A29828@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050323103832.A108873@goliath.americas.sgi.com>
In-Reply-To: <20050323103832.A108873@goliath.americas.sgi.com>; from mraymond@sgi.com on Wed, Mar 23, 2005 at 08:38:33AM -0800
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Michael Raymond <mraymond@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Michael

have you thought about how this infrastructure would play well with 
existing CPU hotplug code for ia64?

Once you return to user mode via the iret, is it possible that user mode
thread could get switched due to a pending cpu quiese attempt to remove
a cpu? (Current cpu removal code would bring the entire system to knees
by scheduling a high priority thread and looping with intr disabled, until the
target cpu is removed)

the cpu removal code would also attempt to migrate user process to another cpu,
retarget interrupts to another existing cpu etc. I havent tested the hotplug
code on sgi boxes so far. (only tested on some hp boxes by Alex Williamson
and on tiger4 boxes so far)

Cheers,
ashok


On Wed, Mar 23, 2005 at 08:38:33AM -0800, Michael Raymond wrote:
> 
>         Allow  fast  (1+us) user notification of device interrupts.  This
>    allows
>    more  powerful  user  I/O  applications to be written.  The process of
>    porting
>    to other architectures is straight forward and fully documented.  More
>    information can be found at [1]http://oss.sgi.com/projects/uli/.
> 
> 
