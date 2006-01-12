From: Paul Jackson <pj@sgi.com>
Date: Thu, 12 Jan 2006 10:31:59 +0000
Subject: Re: [CFT 9/29] Add tiocx bus_type probe/remove methods
Message-Id: <20060112023159.d76f5867.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060105142951.13.01@flint.arm.linux.org.uk>
	<20060105142951.13.09@flint.arm.linux.org.uk>
	<20060112014551.8e7888c3.pj@sgi.com>
In-Reply-To: <20060112014551.8e7888c3.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>
Cc: rmk@arm.linux.org.uk, linux-kernel@vger.kernel.org, greg@kroah.com, linux-ia64@vger.kernel.org

pj wrote:
> This patch looks broken.  I see the lines:
> 
> +	.remove = cx_device_remove,
> -	cx_driver->driver.remove = cx_driver_remove;

It looks like Adrian already posted a patch for this - thanks.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
