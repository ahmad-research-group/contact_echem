contact_echem
=====
Codes, and input files for reproducing the simulation results from the paper: "Constriction and contact impedance of ceramic solid electrolytes" [arXiv preprint](https://arxiv.org/abs/2501.00600)

`contact_echem` is a MOOSE-based application to simulate contact loss in electrochemical systems.

The standard input files for reproducing the results are in `/test/tests/` folder.

"Fork contact_echem" to create a new MOOSE-based application.

For more information see: [http://mooseframework.org/create-an-app/](http://mooseframework.org/create-an-app/)


## How to run

Install MOOSE framework from [https://www.mooseframework.org/getting_started/index.html](https://www.mooseframework.org/getting_started/index.html)
```
git clone https://github.com/ahmad-research-group/contact_echem
cd contact_echem
make -j4
cp contact_echem-opt test/tests/
cd test/tests/
mpirun -np 8 ./contact_echem-opt -i different_contact_area.i
```
## How to cite

```
@article{limon2024constriction,
  title={Constriction and contact impedance of ceramic solid electrolytes},
  author={Limon, Md Salman Rabbi and Duffee, Curtis and Ahmad, Zeeshan},
  journal={arXiv preprint arXiv:2501.00600},
  doi = {10.48550/arXiv.2501.00600},
  year={2024}
}

```
