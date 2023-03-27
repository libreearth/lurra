defmodule Lurra.EcoOasesTest do
  use Lurra.DataCase

  alias Lurra.EcoOases

  describe "eco_oases" do
    alias Lurra.EcoOases.EcoOasis

    import Lurra.EcoOasesFixtures

    @invalid_attrs %{name: nil}

    test "list_eco_oases/0 returns all eco_oases" do
      eco_oasis = eco_oasis_fixture()
      assert EcoOases.list_eco_oases() == [eco_oasis]
    end

    test "get_eco_oasis!/1 returns the eco_oasis with given id" do
      eco_oasis = eco_oasis_fixture()
      assert EcoOases.get_eco_oasis_no_elements!(eco_oasis.id) == eco_oasis
    end

    test "create_eco_oasis/1 with valid data creates a eco_oasis" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %EcoOasis{} = eco_oasis} = EcoOases.create_eco_oasis(valid_attrs)
      assert eco_oasis.name == "some name"
    end

    test "create_eco_oasis/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = EcoOases.create_eco_oasis(@invalid_attrs)
    end

    test "update_eco_oasis/2 with valid data updates the eco_oasis" do
      eco_oasis = eco_oasis_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %EcoOasis{} = eco_oasis} = EcoOases.update_eco_oasis(eco_oasis, update_attrs)
      assert eco_oasis.name == "some updated name"
    end

    test "update_eco_oasis/2 with invalid data returns error changeset" do
      eco_oasis = eco_oasis_fixture()
      assert {:error, %Ecto.Changeset{}} = EcoOases.update_eco_oasis(eco_oasis, @invalid_attrs)
      assert eco_oasis == EcoOases.get_eco_oasis_no_elements!(eco_oasis.id)
    end

    test "delete_eco_oasis/1 deletes the eco_oasis" do
      eco_oasis = eco_oasis_fixture()
      assert {:ok, %EcoOasis{}} = EcoOases.delete_eco_oasis(eco_oasis)
      assert_raise Ecto.NoResultsError, fn -> EcoOases.get_eco_oasis!(eco_oasis.id) end
    end

    test "change_eco_oasis/1 returns a eco_oasis changeset" do
      eco_oasis = eco_oasis_fixture()
      assert %Ecto.Changeset{} = EcoOases.change_eco_oasis(eco_oasis)
    end
  end

  describe "elements" do
    alias Lurra.EcoOases.Element

    import Lurra.EcoOasesFixtures

    @invalid_attrs %{data: nil, name: nil, type: nil}

    test "list_elements/0 returns all elements" do
      element = element_fixture()
      assert EcoOases.list_elements() == [element]
    end

    test "get_element!/1 returns the element with given id" do
      element = element_fixture()
      assert EcoOases.get_element!(element.id) == element
    end

    test "create_element/1 with valid data creates a element" do
      valid_attrs = %{data: "some data", name: "some name", type: "some type"}

      assert {:ok, %Element{} = element} = EcoOases.create_element(valid_attrs)
      assert element.data == "some data"
      assert element.name == "some name"
      assert element.type == "some type"
    end

    test "create_element/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = EcoOases.create_element(@invalid_attrs)
    end

    test "update_element/2 with valid data updates the element" do
      element = element_fixture()
      update_attrs = %{data: "some updated data", name: "some updated name", type: "some updated type"}

      assert {:ok, %Element{} = element} = EcoOases.update_element(element, update_attrs)
      assert element.data == "some updated data"
      assert element.name == "some updated name"
      assert element.type == "some updated type"
    end

    test "update_element/2 with invalid data returns error changeset" do
      element = element_fixture()
      assert {:error, %Ecto.Changeset{}} = EcoOases.update_element(element, @invalid_attrs)
      assert element == EcoOases.get_element!(element.id)
    end

    test "delete_element/1 deletes the element" do
      element = element_fixture()
      assert {:ok, %Element{}} = EcoOases.delete_element(element)
      assert_raise Ecto.NoResultsError, fn -> EcoOases.get_element!(element.id) end
    end

    test "change_element/1 returns a element changeset" do
      element = element_fixture()
      assert %Ecto.Changeset{} = EcoOases.change_element(element)
    end
  end
end
