From: Ben Woodard <woodard@redhat.com>
Date: Tue, 11 Jan 2005 15:46:28 +0000
Subject: new utility for decoding salinfo records
Message-Id: <1105458388.22104.7.camel@quince.llnl.gov>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-3STyggFuMz1VCd6ZPP2h"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-3STyggFuMz1VCd6ZPP2h
Content-Type: text/plain; charset="iso-8859-13"
Content-Transfer-Encoding: quoted-printable

Excuse me if this ends up being a duplicate. I mailed this out last
night but for some reason, it hasn't come through. It is not in the
archives nor have I seen it come back through to my mail box.

Here is a new utility for looking into salinfo records. It several
things differently than salinfo_decode. We have found that this helps
considerably in understanding problem on our itanium servers. The
attached patch applies to salinfo-0.7 and does not modify
salinfo_decode's functioning in any way. In fact the only files that are
modifed are the Makefile and the spec file.

Here is the man page which tries to illustrate some of the features
which were designed into salinfo_decode2.

SALINFO_DECODE2(8)      Decode Itanium SAL Error Records      SALINFO_DECOD=
E2(8)
=20
NAME
       salinfo_decode2 - decode Itanium SAL error records
=20
SYNOPSIS
       salinfo_decode2 [OPTION]... [FILE | DIRECTORY]...
=20
DESCRIPTION
       salinfo_decode2 decodes CMC/CPE/MCA/INIT records obtained from the S=
AL.
       It will take a list of files or directories and print out the reques=
ted
       information  about  the salinfo records that are contained within th=
ose
       files. This is notably different than the salinfo_decode program  wh=
ich
       processes  only a single record at a time. Experience has shown that=
 it
       can be difficult to identify a hardware failure of the  type  found =
 in
       the  salinfo  logs  because the failure results in many salinfo reco=
rds
       being created. salinfo_decode2 allows a system administrator to  gla=
nce
       at  a  directory  full  of errors or some subset of files and obtain=
 an
       overall impression of how meaningful the errors are.  This is  done =
 by
       turning  down  the  verbosity  and  generalizing  what  is  there. M=
ore
       experienced  administrators  can  turn  up  the   verbosity   and   =
get
       progressively more detailed information.
=20
       salinfo_decode2  also  has  the  capability  to generate output that=
 is
       designed to be easily parsed by a machine. This is useful when you w=
ant
       to  automate  monitoring  of  large  numbers  of machines. For examp=
le,
       instead of having scripts notify you every time an ignorable single =
bit
       memory  error  occurs,  the  monitoring scripts can easily ignore th=
ose
       errors and only point out higher priority error conditions.
=20
       If no files or directories are specified on the command line, stdin =
 is
       read and is assumed to be a SAL record.
=20
       salinfo_decode2  also  has the advantage that a SAL record from an i=
a64
       can be inspected and analyzed on a non-ia64, non-little endian machi=
ne.
       For  example,  a  system  administrator  using  an ia32 workstation =
can
       inspect SAL records from an ia64 cluster.  The design of  the  origi=
nal
       salinfo_decode=FFs  internal  architecture  precludes this kind of c=
ross-
       platform utilization.
=20
OPTIONS
       -h, --help
              Print usage and exit
=20
       -V, --version
              Print version information and exit
=20
       -c, --cmc
              Only print cmc records
=20
       -p, --cpe
              Only print cpe records
=20
       -m, --mca
              Only print mca records
=20
       -i, --init
              Only print init records
                                                                           =
    =20
       -d, --dimm-offset
              Count dimms starting at 1 not 0. This is  useful  when  the  =
SAL
              reports  failures  starting with 0 but the numbers silk scree=
ned
              on a the motherboard begin with  1.  This  helps  reduce  sys=
tem
              administrator confusion when replacing the memory DIMM.
=20
       -o, --cpu-offset
              Count  cpus  starting  at  1  not 0. This is useful when the =
SAL
              reports failures starting with 0 but the numbers  silk  scree=
ned
              on  the  motherboard  begin  with  1.  This  helps reduce sys=
tem
              administrator confusion when replacing CPUs.
=20
       --tiger4
              The same as -d & -o. The Intel Tiger 4 motherboard=FFs  silks=
creen
              counts  both CPUs and DIMMs beginning with 1 rather than 0 wh=
ich
              is what the SAL returns.
=20
       -f, --forgiving
              Be forgiving of errors when opening files and reading data
=20
       -r, --recursive
              When a database is a directory traverse its sub-directories
=20
       -v, --verbosity
              Specify the verbosity to print records. Verbosity  can  be  1=
-6.
              However,  as  the  verbosity  increases, the likelihood that =
the
              printing of the detailed information hasn=FFt been implemente=
d yet
              also  increases.  Patches  to  remedy this situation are eage=
rly
              accepted.  The goal with the progressive levels of verbosity =
 is
              to  facilitate  understanding  of records, not just to blurt =
out
              every scrap of  available  information.  Since  verbosity  6 =
 is
              largely  not  implemented  yet,  if  you  need  all of availa=
ble
              information, use the original salinfo_decode.
=20
       -s, --scriptable
              Output in  a  machine  readable  format.  This  is  designed =
 to
              facilitate quick and easy shell scripting with the output. Re=
fer
              to the examples section for intended use.
=20
EXAMPLES
       Pointing salinfo_decode2 at a  directory  of  a  few  errors  with  =
the
       verbosity   set   very  low  shows  that  all  the  errors  are  mai=
nly
       inconsequential:
=20
       $ ./salinfo_decode2 -v1 tigertest/
       cpe with severity "corrected" occurred at 12:03:08 on Apr 1 2004
       cpe with severity "corrected" occurred at 12:03:10 on Apr 1 2004
       cpe with severity "corrected" occurred at 12:32:14 on Apr 1 2004
       cpe with severity "corrected" occurred at 17:24:44 on Apr 1 2004
=20
       Here is an example of how different levels  of  verbosity  present  =
the
       same SAL record differently:
=20
       $ ./salinfo_decode2 -v1 sample_data/tdev2-2004-04-01-12:03:08-cpu1-c=
pe0
       cpe with severity "corrected" occurred at 12:03:08 on Apr 1 2004
                                                                           =
    =20
       $ ./salinfo_decode2 -v2 sample_data/tdev2-2004-04-01-12:03:08-cpu1-c=
pe0
       record 612413502631444488 contains the following sections: (PCI comp=
onent) (PCI component) (PCI component) (PCI component) (memory) (platform s=
pecific)
=20
       $ ./salinfo_decode2 -v3 sample_data/tdev2-2004-04-01-12:03:08-cpu1-c=
pe0
       record 612413502631444488 contains the following sections:
       PCI component with (vend/dev) 8086/500 at (Seg/Bus/Dev/Func) 0/255/2=
4/0 reported a fault
       PCI component with (vend/dev) 8086/501 at (Seg/Bus/Dev/Func) 0/255/2=
4/1 reported a fault
       PCI component with (vend/dev) 8086/502 at (Seg/Bus/Dev/Func) 0/255/2=
4/2 reported a fault
       PCI component with (vend/dev) 8086/503 at (Seg/Bus/Dev/Func) 0/255/2=
4/3 reported a fault
       Memory fault at (node/card/module/bank/device) 0/0/8/0/0
       OEM component with id 0x44fc4766d807e40f reported a fault
=20
       Here is an example of how to use the scriptable interface to change =
the
       formatting of the output and to select one record  out  of  many  wh=
ich
       match a specific criteria.
=20
       $ ./salinfo_decode2 -v1 -s sample_data/ | while read line;do
       > eval $line
       > if [ "$severity" !=3D "corrected" ];then
       >    echo $month/$day/$year
       > fi
       > done
       4/1/2004
=20
BUGS
       Many  levels  of  verbosity  for  many  types  of  errors  are  not =
yet
       implemented. The project reached a state where it did  what  the  us=
ers
       needed  it  to do and then I was asked to work on other things. Patc=
hes
       are greatfully accepted.
=20
AUTHOR
       Ben Woodard <woodard@redhat.com>
=20
SEE ALSO
       salinfo_decode(8)
                                                                           =
    =20
Linux                             Jan 6, 2005                SALINFO_DECODE=
2(8)


--=-3STyggFuMz1VCd6ZPP2h
Content-Disposition: attachment; filename=salinfo_decode2.patch.gz
Content-Type: application/x-gzip; name=salinfo_decode2.patch.gz
Content-Transfer-Encoding: base64

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
5ByXwqlQ/K7g6f8FZve3WpDwAQA=

--=-3STyggFuMz1VCd6ZPP2h--

