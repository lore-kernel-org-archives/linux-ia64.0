From: Christian Hildner <christian.hildner@hob.de>
Date: Fri, 22 Oct 2004 13:06:41 +0000
Subject: Re: request_irq() and setup_irq()
Message-Id: <417905E1.4070404@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4177D1A4.1040009@hob.de>
In-Reply-To: <4177D1A4.1040009@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tian, Kevin schrieb:

>
>ACPI can provide MADT table for lsapic and iosapic info in local system.
From that table, linux will configure interrupt controller info for each
>interrupt line when bootup. You can look at iosapic_init(), which
>constructs per-line info related to iosapic. Say, by trigger mode of
>specific line, register_intr() will decide whether irq_type_iosapic_edge
>or irq_type_iosapic_level should be used. 
>
Kevin,
thanks for your good pointers. Indeed iosapic_init() and register_intr() 
are the choice since they install a handler as needed. But before I had 
to walk through the hell of acpi.

Thanks a lot

Christian

