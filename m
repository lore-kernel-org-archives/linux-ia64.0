From: Jeff Garzik <jgarzik@pobox.com>
Date: Tue, 22 Jun 2004 23:09:52 +0000
Subject: Re: Does parallel make work for modules?
Message-Id: <40D8BC40.9030104@pobox.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622220813.GA306@lucon.org>
In-Reply-To: <20040622220813.GA306@lucon.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. J. Lu" <hjl@lucon.org>
Cc: linux kernel <linux-kernel@vger.kernel.org>, linux ia64 kernel <linux-ia64@vger.kernel.org>

H. J. Lu wrote:
> When building 2.6.7 on a 4way Linux/ia64, "make -j4 modules" doesn't
> spawn 4 jobs. I got


BTW, you don't need to bother with a separate 'make modules' step anymore.

'make -jN' should build everything, including the default boot image for 
your architecture.

	Jeff


