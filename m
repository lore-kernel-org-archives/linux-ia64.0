From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 24 Jan 2002 05:23:21 +0000
Subject: Re: [Linux-ia64] patch for vmlinux.lds.S
Message-Id: <marc-linux-ia64-105590698805923@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805920@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805920@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 23 Jan 2002 21:40:09 -0500, 
Bill Nottingham <notting@redhat.com> wrote:
>Keith Owens (kaos@ocs.com.au) said: 
>> On Wed, 23 Jan 2002 21:23:32 -0500, 
>> Bill Nottingham <notting@redhat.com> wrote:
>> >This fixes building the kernel for me; possibly a recent binutils
>> >thing? (Otherwise, I'm getting dangling references to the
>> >text.exit code in .IA_64.unwind.text.exit sections.)
>> 
>> Which binutils?
>
>2.11.92.0.12 + patches.
>
>> What does "objdump -h init/main.o vmlinux" report?
>  6 .IA_64.unwind_info.text.init 00000130  0000000000000000  0000000000000000  00002380  2**3
>                  CONTENTS, ALLOC, LOAD, READONLY, DATA
>  7 .IA_64.unwind.text.init 000000f0  0000000000000000  0000000000000000  000024b0  2**3
>                  CONTENTS, ALLOC, LOAD, RELOC, DATA
> 10 .IA_64.unwind_info 00000078  0000000000000000  0000000000000000  00002d08  2**3
>                  CONTENTS, ALLOC, LOAD, READONLY, DATA
> 11 .IA_64.unwind 00000060  0000000000000000  0000000000000000  00002d80  2**3
>vmlinux:     file format elf64-ia64-little
>  4 .IA_64.unwind_info 00023c18  e00000000481bf88  000000000481bf88  0042bf88  2**3
>                  CONTENTS, ALLOC, LOAD, READONLY, DATA
>  5 .IA_64.unwind 0001b9f0  e00000000483fba0  000000000483fba0  0044fba0  2**3

Your patch looks OK, I just want to confirm that the binutils change to
generate multiple unwind sections has not broken the requirement that
unwind entries appear in ascending order.  Run this Perl script against
your vmlinux, it should say 0 out of order entries detected.

#!/usr/bin/perl -w
# Verify that ia64 unwind data is valid.
# Needs readelf command from recent binutils.

use strict;
use integer;
die($0 . " takes exactly one argument, the vmlinux to be explored\n") if($#ARGV);

my ($data, $section, $start, $size);
my @f;

open(VMLINUX, $ARGV[0]) || die("cannot open $ARGV[0] for reading");

$data = `readelf -S $ARGV[0] | fgrep -A 1 ' .IA_64.unwind '`;
chomp($data);
$data =~ s/\n/ /m;
die("$0 could not find .IA_64.unwind section in $ARGV[0]\n") if($data eq "");
print("Unwind section ", $data, "\n");
$data =~ s/[][]//g;
(@f) = split(' ', $data);
$section = $f[0];
$start = hex($f[4]);
$size = hex($f[5]);

sysseek(VMLINUX, $start, 0) || die "cannot seek to offset $start in $ARGV[0]";
sysread(VMLINUX, $data, $size) || die "cannot read $size bytes from offset $start in $ARGV[0]";
close(VMLINUX);

my @unwind;
my @previous = (0, 0, 0, 0, 0, 0);
my $i;
my $error = 0;

for ($i = 0; $i < $size; $i += 24) {
	# unpack Q is optional, don't rely on it
	@unwind = unpack("LLLLLL", substr($data, $i, 24));
	if ($unwind[0] < $previous[0] ||
	    $unwind[0] = $previous[0] && $unwind[1] < $previous[1]) {
		printf("Out of order\n");
		printf("start 0x%08x%08x end 0x%08x%08x info 0x%08x%08x\n",
			$previous[1], $previous[0], $previous[3], $previous[2], $previous[5], $previous[4]);
		printf("      0x%08x%08x     0x%08x%08x      0x%08x%08x\n",
			$unwind[1], $unwind[0], $unwind[3], $unwind[2], $unwind[5], $unwind[4]);
		++$error;
	}
	@previous = @unwind;
}

printf("%d out of order entries detected\n", $error);
exit($error);


