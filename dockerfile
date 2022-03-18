Analyzing emad64/smartsim4foam:sing
Docker Version: 19.03.12
GraphDriver: overlay2
Environment Variables
|PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
|solids4Foam=/opt/foam/solids4foam-release
|solids4Foam_SRC=/opt/foam/solids4foam-release/src/
|mlSrc=/smartsim/src/foamClasses4TensorFlowPredictions/src/

Image user
|User is root

Potential secrets:
|Found match etc/ssh/ssh_host_ecdsa_key.pub Possible public key \.pub$ 7a39c51639f46130c19fefd0e46c5a617907d4077d4bdb187db620a5a74538a0/layer.tar
|Found match etc/ssh/ssh_host_ed25519_key.pub Possible public key \.pub$ 7a39c51639f46130c19fefd0e46c5a617907d4077d4bdb187db620a5a74538a0/layer.tar
|Found match etc/ssh/ssh_host_rsa_key.pub Possible public key \.pub$ 7a39c51639f46130c19fefd0e46c5a617907d4077d4bdb187db620a5a74538a0/layer.tar
|Found match etc/ssh/sshd_config Server SSH Config .?sshd_config[\s\S]* 7a39c51639f46130c19fefd0e46c5a617907d4077d4bdb187db620a5a74538a0/layer.tar
|Found match opt/foam/foam-extend-4.0/tutorials/incompressible/simpleFoam/mixingPlaneDomADomB/system/decomposeParDict.backup Contains word: backup \.backup$ 9726480b2521fd1e254dc2522bda73f33b5610d1ecccd5afd430343fd492935f/layer.tar
|Found match etc/ssh/ssh_config Client SSH Config .?ssh_config[\s\S]* e222087517c7d93f035c56359170eb5fc2d1629943afd319fe200268e9cfd86c/layer.tar
Dockerfile:
RUN [ -z "$(apt-get indextargets)" ]
RUN set -xe  \
	&& echo '#!/bin/sh' > /usr/sbin/policy-rc.d  \
	&& echo 'exit 101' >> /usr/sbin/policy-rc.d  \
	&& chmod +x /usr/sbin/policy-rc.d  \
	&& dpkg-divert --local --rename --add /sbin/initctl  \
	&& cp -a /usr/sbin/policy-rc.d /sbin/initctl  \
	&& sed -i 's/^exit.*/exit 0/' /sbin/initctl  \
	&& echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup  \
	&& echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean  \
	&& echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean  \
	&& echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean  \
	&& echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages  \
	&& echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes  \
	&& echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
RUN mkdir -p /run/systemd  \
	&& echo 'docker' > /run/systemd/container
CMD ["/bin/bash"]
MAINTAINER emadUCD<emad.tandis@ucd.ie>
RUN apt-get update
RUN apt install -y vim
RUN apt-get install -y git
RUN apt-get update
RUN apt install -y python3-dev python3-pip
RUN pip3 install -U --user pip six 'numpy<1.19.0' wheel setuptools mock 'future>=0.17.1' 'gast==0.3.3' typing_extensions
RUN pip3 install -U --user keras_applications --no-deps
RUN pip3 install -U --user keras_preprocessing --no-deps
RUN apt-get update
RUN apt-get install -y python
RUN pip3 install pandas
RUN pip3 install sklearn
RUN pip3 install matplotlib
RUN pip3 install Ipython
RUN apt install -y curl gnupg
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
RUN mv bazel.gpg /etc/apt/trusted.gpg.d/
RUN echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
RUN apt install -y protobuf-c-compiler
RUN apt update
RUN apt install -y bazel
RUN git clone https://github.com/tensorflow/tensorflow.git
RUN chmod +x ./tensorflow/configure
RUN chmod +x ./tensorflow/tensorflow/tools/ci_build/install/install_bazel.sh  \
	&& ./tensorflow/tensorflow/tools/ci_build/install/install_bazel.sh
RUN echo "n n n n n n n n n n n n" | ./tensorflow/configure
RUN mkdir /bazel_build
RUN cd ./tensorflow  \
	&& bazel --output_base=/bazel_build build -c opt --config=v2 //tensorflow:libtensorflow.so
RUN cd ./tensorflow  \
	&& bazel --output_base=/bazel_build build -c opt --config=v2 //tensorflow:libtensorflow_cc.so
RUN cd ./tensorflow  \
	&& bazel --output_base=/bazel_build build -c opt --config=v2 //tensorflow/tools/pip_package:build_pip_package
RUN mkdir /tensorflow/bazel-bin/tensorflow/include
RUN cp -a /tensorflow/bazel-bin/tensorflow/tools/pip_package/build_pip_package.runfiles/. /tensorflow/bazel-bin/tensorflow/include/
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/tensorflow/bazel-bin/tensorflow/" >> /root/.bashrc
RUN apt-get install -y git-core build-essential binutils-dev cmake flex bear zlib1g-dev libncurses5-dev libreadline-dev libxt-dev rpm mercurial graphviz python python-dev python3 python3-dev gcc-5 g++-5 gnuplot gnuplot-qt gnuplot-data
RUN cd opt  \
	&& mkdir foam  \
	&& cd foam  \
	&& git clone git://git.code.sf.net/p/foam-extend/foam-extend-4.0 foam-extend-4.0
RUN cd opt/foam/foam-extend-4.0  \
	&& echo "export WM_THIRD_PARTY_USE_BISON_27=1" >> etc/prefs.sh  \
	&& echo "export WM_CC='gcc-5'" >> etc/prefs.sh  \
	&& echo "export WM_CXX='g++-5'" >> etc/prefs.sh  \
	&& echo "export QT_BIN_DIR='/user/bin/'" >> etc/prefs.sh
RUN cd opt/foam/foam-extend-4.0  \
	&& echo "export QT_BIN_DIR='/usr/bin/'" >> etc/prefs.sh
RUN apt install -y mpi
RUN echo "source opt/foam/foam-extend-4.0/etc/bashrc" >> /root/.bashrc
RUN echo "source opt/foam/foam-extend-4.0/etc/bashrc" >> ~/.bashrc
RUN sed -i '0,/public:/s|public:| //Get cell addressing\n const labelList\&\ cellAddress() const\n {\n return cellAddressing_;\n }|g' /opt/foam/foam-extend-4.0/src/sampling/meshToMeshInterpolation/meshToMesh/meshToMesh.H
RUN sed -i "s|//- Return inverse distance weights|public:\n //- Return inverse distance weights|g" /opt/foam/foam-extend-4.0/src/sampling/meshToMeshInterpolation/meshToMesh/meshToMesh.H
RUN sed -i 's|$HOME|/opt|g' /opt/foam/foam-extend-4.0/etc/bashrc
RUN /bin/bash -c ". /opt/foam/foam-extend-4.0/etc/bashrc  \
	&& cd /opt/foam/foam-extend-4.0  \
	&& ./Allwmake.firstInstall"
RUN apt update
RUN cd /opt/foam  \
	&& git clone https://bitbucket.org/philip_cardiff/solids4foam-release.git
ENV solids4Foam=/opt/foam/solids4foam-release
ENV solids4Foam_SRC=/opt/foam/solids4foam-release/src/
RUN cp /opt/foam/solids4foam-release/filesToReplaceInOF/findRefCell.C /opt/foam/foam-extend-4.0/src/finiteVolume/cfdTools/general/findRefCell/
RUN /bin/bash -c ". /opt/foam/foam-extend-4.0/etc/bashrc  \
	&& wmake libso /opt/foam/foam-extend-4.0/src/finiteVolume  \
	&& cd /opt/foam/solids4foam-release  \
	&& ./Allwmake"
RUN chmod +x tensorflow/bazel-bin/tensorflow/tools/pip_package/build_pip_package
RUN /bin/bash -c "cd tensorflow  \
	&& . bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg  \
	&& pip3 install /tmp/tensorflow_pkg/tensorflow*.whl"
RUN mkdir /smartsim
RUN mkdir /smartsim/src
RUN mkdir /smartsim/tutorials
COPY dir:498f621c17960e1ae12f1195bceaba093b0a8b3d376236b7973409b0e7aeb8d4 in /smartsim/src
	smartsim/
	smartsim/src/
	smartsim/src/Allwmake
	smartsim/src/foamClasses4TensorFlowPredictions/
	smartsim/src/foamClasses4TensorFlowPredictions/.wh..wh..opq
	smartsim/src/foamClasses4TensorFlowPredictions/Allwclean
	smartsim/src/foamClasses4TensorFlowPredictions/Allwmake
	smartsim/src/foamClasses4TensorFlowPredictions/README.md
	smartsim/src/foamClasses4TensorFlowPredictions/solver_acceleration/
	smartsim/src/foamClasses4TensorFlowPredictions/solver_acceleration/solids4foam_replace_files/
	smartsim/src/foamClasses4TensorFlowPredictions/solver_acceleration/solids4foam_replace_files/linGeomTotalDispSolid.C
	smartsim/src/foamClasses4TensorFlowPredictions/solver_acceleration/solids4foam_replace_files/linGeomTotalDispSolid.H
	smartsim/src/foamClasses4TensorFlowPredictions/solver_acceleration/solids4foam_replace_files/options
	smartsim/src/foamClasses4TensorFlowPredictions/solver_acceleration/solids4foam_replace_files/solids4foam/
	smartsim/src/foamClasses4TensorFlowPredictions/solver_acceleration/solids4foam_replace_files/solids4foam/options
	smartsim/src/foamClasses4TensorFlowPredictions/src/
	smartsim/src/foamClasses4TensorFlowPredictions/src/Make/
	smartsim/src/foamClasses4TensorFlowPredictions/src/Make/files
	smartsim/src/foamClasses4TensorFlowPredictions/src/Make/options
	smartsim/src/foamClasses4TensorFlowPredictions/src/linearOperation/
	smartsim/src/foamClasses4TensorFlowPredictions/src/linearOperation/Make/
	smartsim/src/foamClasses4TensorFlowPredictions/src/linearOperation/Make/files
	smartsim/src/foamClasses4TensorFlowPredictions/src/linearOperation/Make/options
	smartsim/src/foamClasses4TensorFlowPredictions/src/linearOperation/linOpCoeffGenerator.C
	smartsim/src/foamClasses4TensorFlowPredictions/src/linearOperation/linOpCoeffGenerator.H
	smartsim/src/foamClasses4TensorFlowPredictions/src/machineLearningInitializer/
	smartsim/src/foamClasses4TensorFlowPredictions/src/machineLearningInitializer/machineLearningInitializer.C
	smartsim/src/foamClasses4TensorFlowPredictions/src/machineLearningInitializer/machineLearningInitializer.H
	smartsim/src/foamClasses4TensorFlowPredictions/src/machineLearningModel/
	smartsim/src/foamClasses4TensorFlowPredictions/src/machineLearningModel/machineLearningModel.C
	smartsim/src/foamClasses4TensorFlowPredictions/src/machineLearningModel/machineLearningModel.H
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/.ipynb_checkpoints/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/.ipynb_checkpoints/Untitled-checkpoint.ipynb
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/.ipynb_checkpoints/beam_extract_train_predict-checkpoint.ipynb
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/.ipynb_checkpoints/iteration_data_extraction-checkpoint.ipynb
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/.ipynb_checkpoints/iteration_data_fitting-checkpoint.ipynb
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/.ipynb_checkpoints/test-checkpoint.ipynb
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/.log.solids4Foam.swp
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/0/U
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/dynamicMeshDict.gz
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/constant/rheologyProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-21209.0_996626.0/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/.log.solids4Foam.swp
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/0/U
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/dynamicMeshDict.gz
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/constant/rheologyProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-641222.0_-213952.0/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/.log.solids4Foam.swp
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/0/U
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/dynamicMeshDict.gz
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/constant/rheologyProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-644455.0_159983.0/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/.log.solids4Foam.swp
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/0/U
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/dynamicMeshDict.gz
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/constant/rheologyProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-647471.0_486291.0/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/.log.solids4Foam.swp
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/0/U
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/dynamicMeshDict.gz
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/constant/rheologyProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-649593.0_-763618.0/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/.log.solids4Foam.swp
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/0/U
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/dynamicMeshDict.gz
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/constant/rheologyProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-650623.0_155294.0/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/.log.solids4Foam.swp
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/0/U
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/dynamicMeshDict.gz
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/constant/rheologyProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-652477.0_730702.0/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/.log.solids4Foam.swp
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/0/U
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/dynamicMeshDict.gz
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/constant/rheologyProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/data/test/1.0_1.0-766.0_268898.0/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/frozen/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLInit/frozen/cnn.pb
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/0/D
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/1.05294_0.63059-1045502.0.png
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/F1.05294_0.63059-1045502.0.png
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/case.foam
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/cnn.pb
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/dynamicMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/mechanicalProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/physicsProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/polyMesh/blockMeshDict (copy)
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/constant/solidProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/mask1.05294_0.63059-1045502.0.png
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case1/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/0/D
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/cnn.pb
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/dynamicMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/mechanicalProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/physicsProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/polyMesh/blockMeshDict (copy)
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/constant/solidProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case2/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/0/D
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/1.70657_0.78539-1072437.0.png
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/F1.70657_0.78539-1072437.0.png
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/case.foam
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/case3.OpenFOAM
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/cnn.pb
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/cnn1.pb
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/dynamicMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/mechanicalProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/physicsProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/polyMesh/blockMeshDict (copy)
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/constant/solidProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/mask1.70657_0.78539-1072437.0.png
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/MLSurrogate/case3/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/0/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/0/U
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/1.318_0.8621-1099674.0.png
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/Allclean
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/Allrun
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/F1.318_0.8621-1099674.0.png
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/case.foam
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/cnn.pb
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/dynamicMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/g
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/mapFieldsDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/mechanicalProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/physicsProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/polyMesh/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/polyMesh/blockMeshDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/polyMesh/blockMeshDict (copy)
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/polyMesh/boundary
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/polyMesh/faces
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/polyMesh/neighbour
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/polyMesh/owner
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/polyMesh/points
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/constant/solidProperties
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/mask1.318_0.8621-1099674.0.png
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/system/
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/system/controlDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/system/decomposeParDict
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/system/fvSchemes
	smartsim/src/foamClasses4TensorFlowPredictions/tutorial/linearOp/1.318_0.8621-1099674.0/system/fvSolution
	smartsim/src/foamClasses4TensorFlowPredictions/utility/
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLInit/
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLInit/MLInit.C
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLInit/Make/
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLInit/Make/files
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLInit/Make/options
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLInit/createFields.H
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLInit/createNewMesh.H
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLInit/setupCaseOF.H
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLSurrogate/
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLSurrogate/MLSurrogate.C
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLSurrogate/Make/
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLSurrogate/Make/files
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLSurrogate/Make/options
	smartsim/src/foamClasses4TensorFlowPredictions/utility/MLSurrogate/createFields.H
	smartsim/src/foamUtilties4DataGeneration/
	smartsim/src/foamUtilties4DataGeneration/.wh..wh..opq
	smartsim/src/foamUtilties4DataGeneration/Allwmake
	smartsim/src/foamUtilties4DataGeneration/cartesianMap4Ml/
	smartsim/src/foamUtilties4DataGeneration/cartesianMap4Ml/Make/
	smartsim/src/foamUtilties4DataGeneration/cartesianMap4Ml/Make/files
	smartsim/src/foamUtilties4DataGeneration/cartesianMap4Ml/Make/options
	smartsim/src/foamUtilties4DataGeneration/cartesianMap4Ml/cartesianMap4Ml.C
	smartsim/src/foamUtilties4DataGeneration/cartesianMap4Ml/createCartesianMesh.H
	smartsim/src/foamUtilties4DataGeneration/cartesianMap4Ml/mapData.H
	smartsim/src/foamUtilties4DataGeneration/linOpCoeffGenerator/
	smartsim/src/foamUtilties4DataGeneration/linOpCoeffGenerator/Make/
	smartsim/src/foamUtilties4DataGeneration/linOpCoeffGenerator/Make/files
	smartsim/src/foamUtilties4DataGeneration/linOpCoeffGenerator/Make/options
	smartsim/src/foamUtilties4DataGeneration/linOpCoeffGenerator/linOpCoeffGenerator.C
	smartsim/src/foamUtilties4DataGeneration/ofLinOpGen.odt
	smartsim/src/foamUtilties4DataGeneration/pyLinOpLoss.odt

COPY dir:8fe6e0632176db5f296cfd225f7311484c0934eae1a8734beeb3a47ab9de8803 in /smartsim/tutorials
	smartsim/
	smartsim/tutorials/
	smartsim/tutorials/Allcean
	smartsim/tutorials/Allrun
	smartsim/tutorials/README.md
	smartsim/tutorials/curvedBeam/
	smartsim/tutorials/curvedBeam/.wh..wh..opq
	smartsim/tutorials/curvedBeam/coarse/
	smartsim/tutorials/curvedBeam/coarse/.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/.ipynb-checkpoint
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/CNN-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/again-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/again2-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/again3-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/genral3 (copy)-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/genral3-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/genral3_tmp-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/newLinOP-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/supervised-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/supervised2-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/train_ml_model-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/.ipynb_checkpoints/unsupervised-linOPNew-checkpoint.ipynb
	smartsim/tutorials/curvedBeam/coarse/CNN.ipynb
	smartsim/tutorials/curvedBeam/coarse/baseCase/
	smartsim/tutorials/curvedBeam/coarse/baseCase/0/
	smartsim/tutorials/curvedBeam/coarse/baseCase/0/D
	smartsim/tutorials/curvedBeam/coarse/baseCase/Allclean
	smartsim/tutorials/curvedBeam/coarse/baseCase/Allrun
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/dynamicMeshDict
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/g
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/machineLearningProperties
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/mapFieldsDict
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/mechanicalProperties
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/physicsProperties
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/polyMesh/
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/polyMesh/blockMeshDict
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/polyMesh/blockMeshDict (copy)
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/polyMesh/boundary
	smartsim/tutorials/curvedBeam/coarse/baseCase/constant/solidProperties
	smartsim/tutorials/curvedBeam/coarse/baseCase/system/
	smartsim/tutorials/curvedBeam/coarse/baseCase/system/controlDict
	smartsim/tutorials/curvedBeam/coarse/baseCase/system/decomposeParDict
	smartsim/tutorials/curvedBeam/coarse/baseCase/system/fvSchemes
	smartsim/tutorials/curvedBeam/coarse/baseCase/system/fvSolution
	smartsim/tutorials/curvedBeam/coarse/dataCollection.py
	smartsim/tutorials/curvedBeam/coarse/imageCreation.py
	smartsim/tutorials/curvedBeam/coarse/imageCreation.sh
	smartsim/tutorials/curvedBeam/coarse/train_ml_model.ipynb
	smartsim/tutorials/curvedBeam/coarse/train_ml_model.py
	smartsim/tutorials/evaluateSpeedUp

RUN apt install bc
ENV mlSrc=/smartsim/src/foamClasses4TensorFlowPredictions/src/
RUN /bin/bash -c "cd /smartsim/src  \
	&& ./Allwmake"

