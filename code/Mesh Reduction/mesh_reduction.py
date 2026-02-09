import vtk


def reduce_mesh(mesh_file, target_reduction):
    # Load mesh
    reader = vtk.vtkDataSetReader()
    reader.SetFileName(mesh_file)
    reader.Update()

    # Decimate mesh
    decimate = vtk.vtkDecimatePro()
    decimate.SetInputConnection(reader.GetOutputPort())
    decimate.SetTargetReduction(target_reduction)
    decimate.Update()

    return decimate.GetOutput()




def reduce_mesh_from_path(source_path, save_path, target_reduction):
    
    #Reduce mesh from source_path
    reduced_mesh = reduce_mesh(source_path, target_reduction)
    
    #save mesh to save_path
    writer = vtk.vtkPolyDataWriter()
    writer.SetFileName(save_path)
    writer.SetInputData(reduced_mesh)
    writer.Write()
    

source_path = './meshes/PA00005.vtk'
save_path = './meshes/reduced/PA00005.vtk'
target_reduction = 0.9 #90% reduction, for example

reduce_mesh_from_path(source_path, save_path, target_reduction)