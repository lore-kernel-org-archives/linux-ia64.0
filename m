From: Len Brown <lenb@kernel.org>
Date: Tue, 05 Feb 2008 21:03:30 +0000
Subject: Re: [PATCH 0/5] WMI patches for acpi-test (v2)
Message-Id: <200802051603.30466.lenb@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080205021658.4422.83165.stgit@pacifica>
In-Reply-To: <20080205021658.4422.83165.stgit@pacifica>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Carlos Corbacho <carlos@strangeworlds.co.uk>
Cc: linux-acpi@vger.kernel.org, Matthew Garrett <mjg59@srcf.ucam.org>, Alexey Starikovskiy <aystarik@gmail.com>, linux-ia64@vger.kernel.org

On Monday 04 February 2008 21:16, Carlos Corbacho wrote:

> 2) Do you know of any IA64 systems using ACPI-WMI? At the moment, WMI will work
> on x86 and hopefully IA64, but if it turns out that no vendor has or ever will
> implement ACPI-WMI on IA64, then we could safely drop it there.

I recommend skipping WMI on IA64 unless/until a real need to support it emerges.
There are no WMI extensions on the Intel Tiger or Hitachi Fusion IA64 boxes I have access to.

thanks,
-Len

