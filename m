From: Matt Domsch <Matt_Domsch@dell.com>
Date: Mon, 17 Nov 2003 15:10:08 +0000
Subject: Re: Creating New EFI variables in Red Hat AS 2.1
Message-Id: <marc-linux-ia64-106908201020280@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106908087618714@msgid-missing>
In-Reply-To: <marc-linux-ia64-106908087618714@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> For one of my application, I want to create a new EFI variable from the OS.
> The contents of this EFI variable will be used by and EFI application
> running at the EFI shell.
> How do I do it? Can any one Please explain?

Please see the source code for efibootmgr.  This is the only application 
I'm aware of that creates/deletes/changes EFI variables from within the OS 
at present.  http://domsch.com/linux/ia64/efibootmgr/.  Version 0.4.2 is 
the most recent released.  There's a test version 0.5.0-test1 in the 
testing directory there which handles both the 2.4.x kernel style EFI 
variables, and the new sysfs-based style on 2.6.x (if/when that patch is 
submitted and accepted - hint hint Matt T.).    You'll want your app to be 
able to handle both I'm certain.  efibootmgr is licensed under the GNU 
GPL.

Essentially, you fill out a structure, open a file, and write the 
structure to the file.  The structure contains your variable name, GUID, 
data, and properties.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

