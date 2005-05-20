From: Greg Edwards <edwardsg@sgi.com>
Date: Fri, 20 May 2005 18:50:45 +0000
Subject: Re: [PATCH]: TIOCX: Do not autoload TIOCX & FPGA drivers
Message-Id: <20050520185045.GE20644@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050520131215.19334.51045.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20050520131215.19334.51045.sendpatchset@prarit.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 20, 2005 at 09:12:29AM -0400, Prarit Bhargava wrote:
| [PATCH]: ia64/sn : Do not autoload TIOCX & FPGA driver
| 
| When built-in the TIOCX driver has functions exposed to the FPGA driver
| in the kernel.  If a TIOCX is not found, this can lead to an oops when the
| FPGA attempts to register against the TIOCX driver.
| 
| This fix makes found_tiocx_device a static int which is queried when FPGA
| driver(s) attempt to register against the TIOCX driver.  The functions
| cx_driver_register and cx_driver_unregister now return -ENODEV and NULL
| respectively if nr_tiocx_found = 0, preventing the FPGA driver from loading.

Let's hold off on this until we understand the problem a little better.
This seems to be dependent on config settings.  For example, it works fine
to have TIOCX and MBCS compiled statically if the kernel is compiled
CONFIG_IA64_SGI_SN2.

Greg
