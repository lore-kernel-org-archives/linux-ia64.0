From: Khalid Aziz <khalid@fc.hp.com>
Date: Thu, 16 Nov 2000 19:12:39 +0000
Subject: [Linux-ia64] Non-legacy serial port console support using SPCR table in ACPI 2.0
Message-Id: <marc-linux-ia64-105590678205734@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am bringing Linux up on a McKinley platform simulator. For the
bringup, I am looking into adding support for non-legacy serial port
console. ACPI 2.0 includes a Serial Port Console Redirection Table which
defines the serial port console (SPCR table definition can be found at
<http://www.microsoft.com/hwdev/headless/download/SerialPortRedir.zip>).
I am looking into adding support for the serial port defined by this
table. I would also like to add support for the Debug Port as defined by
the Debug Port Table (DBGP table definition can be found at
<http://www.microsoft.com/hwdev/newPC/debugspec.htm>.

Is anyone else looking into doing this? If so, please let me know so we
can collaborate and not have duplication of effort.

-- 
Khalid

==================================
Khalid Aziz                             Linux Development Laboratory
(970)898-9214                                        Hewlett-Packard
khalid@fc.hp.com                                    Fort Collins, CO

