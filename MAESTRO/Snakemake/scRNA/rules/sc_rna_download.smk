
import os


def _quoted_urls(wildcards, read_key):
    """Return all URLs for a sample/read as a space-separated, quoted string."""
    return ' '.join('"{}"'.format(url) for url in FILES[wildcards.sample][read_key])


if config["platform"] in ["10x-genomics", "Dropseq"]:
    rule download_fastq:
        """Download all FASTQ files for a sample. Multiple URLs are concatenated by wget."""
        output:
            r1 = temp("Result/Fastq/{sample}/{sample}_R1.fastq.gz"),
            r2 = temp("Result/Fastq/{sample}/{sample}_R2.fastq.gz"),
        params:
            r1_urls = lambda wildcards: _quoted_urls(wildcards, "R1"),
            r2_urls = lambda wildcards: _quoted_urls(wildcards, "R2"),
        log:
            "Result/Log/{sample}_download.log"
        benchmark:
            "Result/Benchmark/{sample}/{sample}_Download.benchmark"
        shell:
            """
            wget -O {output.r1} {params.r1_urls} >> {log} 2>&1
            wget -O {output.r2} {params.r2_urls} >> {log} 2>&1
            """
