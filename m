From: Joerg Roedel <joro@8bytes.org>
Date: Thu, 07 Aug 2008 10:10:15 +0000
Subject: [IA64] defconfig build failure in current linus.git
Message-Id: <20080807101015.GB4342@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

I just tried to build the current linus.git kernel for IA64 and got the
following build errors:

  CC      drivers/acpi/utils.o
In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:54,
                 from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
/data2/repos/tip/linux.trees.git/include/acpi/platform/acenv.h:175:1: warning: "COMPILER_DEPENDENT_INT64" redefined
In file included from /data2/repos/tip/linux.trees.git/arch/ia64/include/asm/topology.h:14,
                 from /data2/repos/tip/linux.trees.git/include/linux/topology.h:34,
                 from /data2/repos/tip/linux.trees.git/include/linux/mmzone.h:683,
                 from /data2/repos/tip/linux.trees.git/include/linux/gfp.h:4,
                 from /data2/repos/tip/linux.trees.git/include/linux/kmod.h:22,
                 from /data2/repos/tip/linux.trees.git/include/linux/module.h:13,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:27:
/data2/repos/tip/linux.trees.git/arch/ia64/include/asm/acpi.h:38:1: warning: this is the location of the previous definition
In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:54,
                 from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
/data2/repos/tip/linux.trees.git/include/acpi/platform/acenv.h:176:1: warning: "COMPILER_DEPENDENT_UINT64" redefined
In file included from /data2/repos/tip/linux.trees.git/arch/ia64/include/asm/topology.h:14,
                 from /data2/repos/tip/linux.trees.git/include/linux/topology.h:34,
                 from /data2/repos/tip/linux.trees.git/include/linux/mmzone.h:683,
                 from /data2/repos/tip/linux.trees.git/include/linux/gfp.h:4,
                 from /data2/repos/tip/linux.trees.git/include/linux/kmod.h:22,
                 from /data2/repos/tip/linux.trees.git/include/linux/module.h:13,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:27:
/data2/repos/tip/linux.trees.git/arch/ia64/include/asm/acpi.h:39:1: warning: this is the location of the previous definition
In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:55,
                 from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
/data2/repos/tip/linux.trees.git/include/acpi/actypes.h:55:2: error: #error ACPI_MACHINE_WIDTH not defined
/data2/repos/tip/linux.trees.git/include/acpi/actypes.h:141:5: warning: "ACPI_MACHINE_WIDTH" is not defined
/data2/repos/tip/linux.trees.git/include/acpi/actypes.h:180:7: warning: "ACPI_MACHINE_WIDTH" is not defined
/data2/repos/tip/linux.trees.git/include/acpi/actypes.h:202:2: error: #error unknown ACPI_MACHINE_WIDTH
/data2/repos/tip/linux.trees.git/include/acpi/actypes.h:332:5: warning: "ACPI_MACHINE_WIDTH" is not defined
In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:55,
                 from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
/data2/repos/tip/linux.trees.git/include/acpi/actypes.h:683: error: expected specifier-qualifier-list before ‘acpi_io_address’
/data2/repos/tip/linux.trees.git/include/acpi/actypes.h:710: error: expected specifier-qualifier-list before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/actypes.h:786: error: expected declaration specifiers or ‘...’ before ‘acpi_physical_address’
/data2/repos/tip/linux.trees.git/include/acpi/actypes.h:882: error: expected specifier-qualifier-list before ‘acpi_physical_address’
In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:57,
                 from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
/data2/repos/tip/linux.trees.git/include/acpi/acmacros.h:119:5: warning: "ACPI_MACHINE_WIDTH" is not defined
/data2/repos/tip/linux.trees.git/include/acpi/acmacros.h:259:5: warning: "ACPI_MACHINE_WIDTH" is not defined
/data2/repos/tip/linux.trees.git/include/acpi/acmacros.h:262:7: warning: "ACPI_MACHINE_WIDTH" is not defined
/data2/repos/tip/linux.trees.git/include/acpi/acmacros.h:266:2: error: #error unknown ACPI_MACHINE_WIDTH
In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:59,
                 from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
/data2/repos/tip/linux.trees.git/include/acpi/aclocal.h:137: error: expected specifier-qualifier-list before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/aclocal.h:222: error: expected specifier-qualifier-list before ‘acpi_physical_address’
/data2/repos/tip/linux.trees.git/include/acpi/aclocal.h:517: error: expected specifier-qualifier-list before ‘acpi_size’
In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:61,
                 from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:88: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘acpi_os_get_root_pointer’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:105: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘acpi_os_acquire_lock’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:107: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:144: error: expected ‘)’ before ‘size’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:146: error: expected ‘)’ before ‘where’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:149: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:190: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘acpi_os_get_thread_id’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:205: error: expected ‘)’ before ‘address’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:207: error: expected ‘)’ before ‘address’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:213: error: expected ‘)’ before ‘address’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:216: error: expected ‘)’ before ‘address’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:245: error: expected declaration specifiers or ‘...’ before ‘acpi_physical_address’
/data2/repos/tip/linux.trees.git/include/acpi/acpiosxf.h:246: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:62,
                 from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
/data2/repos/tip/linux.trees.git/include/acpi/acpixf.h:101: error: expected ‘)’ before ‘*’ token
/data2/repos/tip/linux.trees.git/include/acpi/acpixf.h:323: error: expected ‘)’ before ‘physical_address’
In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:63,
                 from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
/data2/repos/tip/linux.trees.git/include/acpi/acobject.h:59:5: warning: "ACPI_MACHINE_WIDTH" is not defined
In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:63,
                 from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
/data2/repos/tip/linux.trees.git/include/acpi/acobject.h:159: error: expected specifier-qualifier-list before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acobject.h:172: error: expected specifier-qualifier-list before ‘acpi_physical_address’
/data2/repos/tip/linux.trees.git/include/acpi/acobject.h:220: error: expected specifier-qualifier-list before ‘acpi_io_address’
In file included from /data2/repos/tip/linux.trees.git/include/acpi/acpi.h:67,
                 from /data2/repos/tip/linux.trees.git/include/acpi/acpi_bus.h:31,
                 from /data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:30:
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:94: error: expected specifier-qualifier-list before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:151: error: expected ‘=’, ‘,’, ‘;’, ‘asm’ or ‘__attribute__’ before ‘acpi_ut_strlen’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:156: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:158: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:160: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:167: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:173: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:175: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:404: error: expected ‘)’ before ‘buffer_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:406: error: expected ‘)’ before ‘string_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:409: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:511: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:551: error: expected declaration specifiers or ‘...’ before ‘acpi_size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:553: error: expected ‘)’ before ‘size’
/data2/repos/tip/linux.trees.git/include/acpi/acutils.h:556: error: expected ‘)’ before ‘size’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c: In function ‘acpi_extract_package’:
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:72: error: ‘struct acpi_buffer’ has no member named ‘pointer’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:72: error: ‘struct acpi_buffer’ has no member named ‘length’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:82: error: ‘struct acpi_buffer’ has no member named ‘length’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:90: error: ‘struct acpi_buffer’ has no member named ‘pointer’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:167: error: ‘struct acpi_buffer’ has no member named ‘length’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:168: error: ‘struct acpi_buffer’ has no member named ‘length’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:170: error: ‘struct acpi_buffer’ has no member named ‘length’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:170: error: ‘struct acpi_buffer’ has no member named ‘pointer’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:174: error: ‘struct acpi_buffer’ has no member named ‘pointer’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:175: error: ‘struct acpi_buffer’ has no member named ‘pointer’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c: In function ‘acpi_evaluate_integer’:
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:263: warning: excess elements in struct initializer
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:263: warning: (near initialization for ‘buffer’)
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:263: warning: excess elements in struct initializer
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:263: warning: (near initialization for ‘buffer’)
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:273: error: ‘struct acpi_buffer’ has no member named ‘length’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:274: error: ‘struct acpi_buffer’ has no member named ‘pointer’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c: In function ‘acpi_evaluate_reference’:
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:352: error: ‘acpi_size’ undeclared (first use in this function)
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:352: error: (Each undeclared identifier is reported only once
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:352: error: for each function it appears in.)
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:352: warning: excess elements in struct initializer
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:352: warning: (near initialization for ‘buffer’)
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:352: warning: excess elements in struct initializer
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:352: warning: (near initialization for ‘buffer’)
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:366: error: ‘struct acpi_buffer’ has no member named ‘pointer’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:368: error: ‘struct acpi_buffer’ has no member named ‘length’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:370: error: ‘struct acpi_buffer’ has no member named ‘length’
/data2/repos/tip/linux.trees.git/drivers/acpi/utils.c:429: error: ‘struct acpi_buffer’ has no member named ‘pointer’
make[3]: *** [drivers/acpi/utils.o] Error 1
make[2]: *** [drivers/acpi] Error 2
make[1]: *** [drivers] Error 2
make: *** [sub-make] Error 2

Regards,

Joerg
