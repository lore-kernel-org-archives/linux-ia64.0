From: Dave Jones <davej@redhat.com>
Date: Fri, 10 Sep 2010 02:55:24 +0000
Subject: Re: Serious problem with ticket spinlocks on ia64
Message-Id: <20100910025523.GC31280@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <201008271537.35709.ptesarik@suse.cz>
 <AANLkTimCOWvBs1pdWeMZD9DR=u2ioFPXt7Jja73VQaZn@mail.gmail.com>
 <201009031104.38433.ptesarik@suse.cz>
 <201009031635.25093.ptesarik@suse.cz>
In-Reply-To: <201009031635.25093.ptesarik@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Petr Tesarik <ptesarik@suse.cz>
Cc: Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Sep 03, 2010 at 04:35:23PM +0200, Petr Tesarik wrote:
 
 > I didn't see values around zero on any other CPU in the system. So, either 
 > there is something seriously broken in hardware, or I made a silly mistake in 
 > the monitoring code.

 ...

 > 	memset(dbr, sizeof dbr, 0);
                    ^^^^^^^^^^^^^
swapped arguments.  Perhaps unrelated to the problem, but still silly :)

	Dave

