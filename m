From: "Yu, Luming" <luming.yu@intel.com>
Date: Mon, 23 Jun 2003 06:15:07 +0000
Subject: [Linux-ia64] RE: [ACPI] acpi_irq_to_vector()
Message-Id: <marc-linux-ia64-105634899406952@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105634836206576@msgid-missing>
In-Reply-To: <marc-linux-ia64-105634836206576@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

To remove the ugly ifdef in the common part of ACPI code, 
I think the simple way is to define a acpi_irq_to_vector in arch/i386/acpi which only return acpi_fadt.sci_int. 
Or someone can invent a method that can return correct value for each platform.

Thanks,
Luming

-----Original Message-----
From: Matthew Wilcox [mailto:willy@debian.org]
Sent: 2003?6?6? 3:23
To: acpi-devel@lists.sourceforge.net
Subject: [ACPI] acpi_irq_to_vector()



In the 2.5 ia64 patch, there's a lot of places which look like this:

@@ -251,7 +251,14 @@
        irq = acpi_fadt.sci_int;

 #ifdef CONFIG_IA64
-       irq = gsi_to_vector(irq);
+       int vector;
+
+       vector = acpi_irq_to_vector(irq);
+       if (vector < 0) {
+               printk(KERN_ERR PREFIX "SCI (IRQ%d) not registerd\n", irq);
+               return AE_OK;
+       }
+       irq = vector;
 #endif
        acpi_irq_irq = irq;

ok, we renamed gsi_to_vector to acpi_irq_to_vector(); that's fine.
But we still have that ugly ifdef in there.  Any resistance to defining
acpi_irq_to_vector to simply return its value on non-ia64 platforms?

Then it'd look like:

	irq = acpi_fadt.sci_int;
	vector = acpi_irq_to_vector(irq);
	if (vector < 0) {
		printk(KERN_ERR PREFIX "SCI (IRQ%d) not registered\n", irq);
		return AE_OK;
	}
	acpi_irq_irq = vector;
	acpi_irq_handler = handler;
	acpi_irq_context = context;
	if (request_irq(vector, acpi_irq, SA_SHIRQ, "acpi", acpi_irq)) {
...		

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk


-------------------------------------------------------
This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
thread debugger on the planet. Designed with thread debugging features
you've never dreamed of, try TotalView 6 free at www.etnus.com.
_______________________________________________
Acpi-devel mailing list
Acpi-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/acpi-devel

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64
