From: Arun Sharma <arun.sharma@intel.com>
Date: Tue, 13 Apr 2004 20:30:55 +0000
Subject: Re: 32 bit application on IA-64 Linux
Message-Id: <407C4DFF.3090202@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040412042150.30706.qmail@web13122.mail.yahoo.com>
In-Reply-To: <20040412042150.30706.qmail@web13122.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 4/11/2004 9:21 PM, Srikanta R wrote:

> Hi,
> 
> I need to compile a 32 bit application on a IA-64
> Linux system, that will run on IA-64 system. I didn't
> find any such option for the compiler on IA-64 Linux
> system. Can someone suggest how can I get this done ?

You can install a 32 bit toolchain (compiler + binutils) into /emul/ia32-linux and do this.

	-Arun

